#!/usr/bin/env python3
import argparse
import json
import os
import signal
import socket
import sys

from faster_whisper import WhisperModel


def log(msg: str) -> None:
    print(msg, flush=True)


class Server:
    def __init__(self, socket_path: str, model_name: str, language: str):
        self.socket_path = socket_path
        self.model_name = model_name
        self.language = language
        self.model = None
        self._sock = None
        self._running = True

    def load(self) -> None:
        log(f"loading model={self.model_name} language={self.language or 'auto'}")
        self.model = WhisperModel(self.model_name, device="cpu", compute_type="int8")
        log("model loaded")

    def cleanup(self) -> None:
        if self._sock is not None:
            try:
                self._sock.close()
            except Exception:
                pass
        try:
            os.unlink(self.socket_path)
        except FileNotFoundError:
            pass
        except Exception as e:
            log(f"socket cleanup warning: {e}")

    def handle(self, request: dict) -> dict:
        cmd = request.get("cmd")
        if cmd == "ping":
            return {
                "status": "ok",
                "model": self.model_name,
                "language": self.language,
                "ready": self.model is not None,
            }

        if cmd != "transcribe":
            return {"status": "error", "error": f"unknown cmd: {cmd}"}

        wav_path = request.get("wav")
        language = request.get("language", self.language)
        if not wav_path:
            return {"status": "error", "error": "missing wav"}
        if not os.path.exists(wav_path):
            return {"status": "error", "error": f"wav not found: {wav_path}"}

        segments, info = self.model.transcribe(
            wav_path,
            language=(language.strip() or None) if isinstance(language, str) else None,
        )
        text = " ".join(s.text.strip() for s in segments).strip()
        return {
            "status": "ok",
            "text": text,
            "language": getattr(info, "language", None),
            "duration": getattr(info, "duration", None),
        }

    def serve(self) -> None:
        self.cleanup()
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self._sock = sock
        sock.bind(self.socket_path)
        os.chmod(self.socket_path, 0o600)
        sock.listen(5)
        log(f"listening on {self.socket_path}")

        while self._running:
            try:
                conn, _ = sock.accept()
            except OSError:
                break
            with conn:
                try:
                    data = b""
                    while True:
                        chunk = conn.recv(65536)
                        if not chunk:
                            break
                        data += chunk
                        if b"\n" in chunk:
                            break

                    raw = data.decode("utf-8", errors="replace").strip()
                    if not raw:
                        response = {"status": "error", "error": "empty request"}
                    else:
                        request = json.loads(raw)
                        response = self.handle(request)
                except Exception as e:
                    response = {"status": "error", "error": str(e)}

                conn.sendall((json.dumps(response, ensure_ascii=False) + "\n").encode("utf-8"))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--socket", default=os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "hermeskey.sock"))
    parser.add_argument("--model", default=os.environ.get("MODEL", "medium"))
    parser.add_argument("--lang", default=os.environ.get("STT_LANG", "en"))
    args = parser.parse_args()

    server = Server(args.socket, args.model, args.lang)

    def stop(*_args):
        server._running = False
        server.cleanup()
        sys.exit(0)

    signal.signal(signal.SIGINT, stop)
    signal.signal(signal.SIGTERM, stop)

    server.load()
    server.serve()
    server.cleanup()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
