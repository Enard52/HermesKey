#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_STT_DEFAULT="${PYTHON_STT:-$HOME/venvs/stt/bin/python}"
SERVER_SCRIPT_DEFAULT="${SERVER_SCRIPT:-$SCRIPT_DIR/ptt_stt_server.py}"
OVERLAY_SCRIPT_DEFAULT="${OVERLAY_SCRIPT:-$SCRIPT_DIR/ptt_stt_overlay.py}"

MODEL="${MODEL:-medium}"
STT_LANG="${STT_LANG:-en}"

WAV="/tmp/ptt_stt_audio.wav"
STATE="/tmp/ptt_stt_recording.pid"
OVERLAY_STATE="/tmp/ptt_stt_overlay.pid"
SOCK="/tmp/ptt_stt.sock"
SERVER_PID="/tmp/ptt_stt_server.pid"
TARGET_STATE="/tmp/ptt_stt_target.env"

RECORD_SOURCE="${RECORD_SOURCE:-alsa_input.usb-Beyerdynamic_FOX_5.00-00.mono-fallback}"
CLIP_CMD="${CLIP_CMD:-wl-copy}"
INSERT_MODE="${INSERT_MODE:-type}"
COPY_TO_CLIPBOARD="${COPY_TO_CLIPBOARD:-1}"
TYPE_BACKEND="${TYPE_BACKEND:-auto}"
YDOTOOL_SOCKET_PATH="${YDOTOOL_SOCKET_PATH:-}"
FOCUS_SAFE_MODE="${FOCUS_SAFE_MODE:-0}"
OVERLAY_ENABLED="${OVERLAY_ENABLED:-1}"
SOUND_ENABLED="${SOUND_ENABLED:-1}"
START_TONE_HZ="${START_TONE_HZ:-660}"
STOP_TONE_HZ="${STOP_TONE_HZ:-520}"
TONE_DURATION="${TONE_DURATION:-0.035}"
TONE_VOLUME="${TONE_VOLUME:-0.20}"
TERMINAL_APPS="${TERMINAL_APPS:-org.wezfurlong.wezterm,org.kde.konsole,kitty,Alacritty,ghostty,foot,gnome-terminal,tilix,xfce4-terminal}"
PASTE_FOR_APPS="${PASTE_FOR_APPS:-$TERMINAL_APPS}"
PASTE_SHORTCUT="${PASTE_SHORTCUT:-auto}"
PYTHON_STT="$PYTHON_STT_DEFAULT"
SERVER_SCRIPT="$SERVER_SCRIPT_DEFAULT"
OVERLAY_SCRIPT="$OVERLAY_SCRIPT_DEFAULT"

LOG="/tmp/ptt_stt_debug.log"
SERVER_LOG="/tmp/ptt_stt_server.log"
OVERLAY_LOG="/tmp/ptt_stt_overlay.log"

touch "$LOG"

log() { echo "[$(date '+%F %T')] $*" | tee -a "$LOG"; }

play_tone() {
  local freq="$1"
  [[ "$SOUND_ENABLED" == "1" ]] || return 0

  if command -v paplay >/dev/null 2>&1; then
    (
      python3 - "$freq" "$TONE_DURATION" "$TONE_VOLUME" <<'PY' | paplay --raw --channels=1 --rate=44100 --format=s16le
import math
import struct
import sys

freq = float(sys.argv[1])
duration = float(sys.argv[2])
volume = float(sys.argv[3])
rate = 44100
amp = int(32767 * max(0.02, min(volume, 1.0)))
frames = max(1, int(rate * duration))
attack = max(1, int(rate * 0.008))
release = max(1, int(rate * 0.020))

buf = bytearray()
for i in range(frames):
    env_a = min(1.0, i / attack)
    env_r = min(1.0, (frames - i) / release)
    env = min(env_a, env_r)
    sample = int(math.sin(2 * math.pi * freq * i / rate) * amp * env)
    buf += struct.pack('<h', sample)

sys.stdout.buffer.write(buf)
PY
    ) >/dev/null 2>&1 &
    return 0
  fi

  if command -v canberra-gtk-play >/dev/null 2>&1; then
    canberra-gtk-play -i bell -d hermeskey >/dev/null 2>&1 &
  fi
}

query_active_app() {
  local prefix="${1:-APP_}"
  if ! command -v qdbus >/dev/null 2>&1; then
    printf "%sUUID=''\n%sDESKTOP_FILE=''\n%sRESOURCE_CLASS=''\n%sCAPTION=''\n%sPID=''\n" \
      "$prefix" "$prefix" "$prefix" "$prefix" "$prefix"
    return 0
  fi

  qdbus org.kde.KWin /KWin org.kde.KWin.queryWindowInfo 2>/dev/null | python3 - "$prefix" <<'PY'
import shlex
import sys

prefix = sys.argv[1]
data = {}
for line in sys.stdin:
    line = line.rstrip("\n")
    if ": " not in line:
        continue
    key, value = line.split(": ", 1)
    if key in {"uuid", "desktopFile", "resourceClass", "caption", "pid"}:
        data[key] = value

mapping = {
    "uuid": "UUID",
    "desktopFile": "DESKTOP_FILE",
    "resourceClass": "RESOURCE_CLASS",
    "caption": "CAPTION",
    "pid": "PID",
}
for src, dest in mapping.items():
    print(f"{prefix}{dest}={shlex.quote(data.get(src, ''))}")
PY
}

capture_target_app() {
  query_active_app TARGET_ >"$TARGET_STATE"
  # shellcheck disable=SC1090
  source "$TARGET_STATE"
  log "Target app: ${TARGET_DESKTOP_FILE:-?} | ${TARGET_RESOURCE_CLASS:-?} | ${TARGET_CAPTION:-?} | ${TARGET_UUID:-?}"
}

load_target_app() {
  TARGET_UUID=""
  TARGET_DESKTOP_FILE=""
  TARGET_RESOURCE_CLASS=""
  TARGET_CAPTION=""
  TARGET_PID=""
  if [[ -f "$TARGET_STATE" ]]; then
    # shellcheck disable=SC1090
    source "$TARGET_STATE"
  fi
}

load_current_app() {
  eval "$(query_active_app CURRENT_)"
}

app_matches_patterns() {
  local patterns="$1"
  local desktop_file="$2"
  local resource_class="$3"
  local caption="$4"
  [[ -n "$patterns" ]] || return 1

  python3 - "$patterns" "$desktop_file" "$resource_class" "$caption" <<'PY'
import re
import sys

patterns = [p.strip() for p in sys.argv[1].split(',') if p.strip()]
hay = "\n".join(sys.argv[2:])
for pattern in patterns:
    if re.search(pattern, hay, flags=re.IGNORECASE):
        raise SystemExit(0)
raise SystemExit(1)
PY
}

choose_paste_shortcut() {
  local desktop_file="$1"
  local resource_class="$2"
  local caption="$3"

  if [[ "$PASTE_SHORTCUT" != "auto" ]]; then
    echo "$PASTE_SHORTCUT"
    return 0
  fi

  if app_matches_patterns "$TERMINAL_APPS" "$desktop_file" "$resource_class" "$caption"; then
    echo ctrl-shift-v
  else
    echo ctrl-v
  fi
}

focus_is_safe() {
  [[ "$FOCUS_SAFE_MODE" == "1" ]] || return 0

  load_target_app
  load_current_app

  if [[ -z "$TARGET_UUID" || -z "$CURRENT_UUID" ]]; then
    return 0
  fi

  if [[ "$TARGET_UUID" == "$CURRENT_UUID" ]]; then
    return 0
  fi

  log "Focus changed: target=${TARGET_DESKTOP_FILE:-?}/${TARGET_UUID:-?} current=${CURRENT_DESKTOP_FILE:-?}/${CURRENT_UUID:-?}"
  return 1
}

hide_overlay() {
  [[ "$OVERLAY_ENABLED" == "1" ]] || return 0
  if [[ -f "$OVERLAY_STATE" ]]; then
    local pid
    pid="$(cat "$OVERLAY_STATE" 2>/dev/null || true)"
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
    fi
    rm -f "$OVERLAY_STATE"
  fi
}

show_overlay() {
  [[ "$OVERLAY_ENABLED" == "1" ]] || return 0
  local mode="$1"
  hide_overlay
  nohup python3 "$OVERLAY_SCRIPT" "$mode" >>"$OVERLAY_LOG" 2>&1 &
  echo $! >"$OVERLAY_STATE"
}

server_ping() {
  printf '%s\n' '{"cmd":"ping"}' | nc -U "$SOCK" -w 1 >/dev/null 2>&1
}

detect_type_backend() {
  if [[ "$TYPE_BACKEND" != "auto" ]]; then
    echo "$TYPE_BACKEND"
    return 0
  fi

  if command -v ydotool >/dev/null 2>&1 || [[ -x /usr/bin/ydotool ]]; then
    echo ydotool
    return 0
  fi
  if command -v wtype >/dev/null 2>&1 || [[ -x /usr/bin/wtype ]]; then
    echo wtype
    return 0
  fi
  if command -v xdotool >/dev/null 2>&1 || [[ -x /usr/bin/xdotool ]]; then
    echo xdotool
    return 0
  fi

  echo none
}

copy_text() {
  local text="$1"
  if [[ "$COPY_TO_CLIPBOARD" == "1" ]]; then
    echo -n "$text" | "$CLIP_CMD"
    log "Copied transcription to clipboard (${#text} chars)."
  fi
}

resolve_ydotool_socket() {
  local ysock
  ysock="${YDOTOOL_SOCKET_PATH:-${YDOTOOL_SOCKET:-}}"
  if [[ -z "$ysock" ]]; then
    if [[ -S "/run/user/$UID/.ydotool_socket" ]]; then
      ysock="/run/user/$UID/.ydotool_socket"
    elif [[ -S "/tmp/.ydotool_socket" ]]; then
      ysock="/tmp/.ydotool_socket"
    else
      ysock="/run/user/$UID/.ydotool_socket"
    fi
  fi
  printf '%s\n' "$ysock"
}

type_text() {
  local text="$1"
  local backend ydotool_bin wtype_bin xdotool_bin ysock
  backend="$(detect_type_backend)"
  ydotool_bin="$(command -v ydotool 2>/dev/null || true)"
  wtype_bin="$(command -v wtype 2>/dev/null || true)"
  xdotool_bin="$(command -v xdotool 2>/dev/null || true)"
  [[ -n "$ydotool_bin" ]] || ydotool_bin=/usr/bin/ydotool
  [[ -n "$wtype_bin" ]] || wtype_bin=/usr/bin/wtype
  [[ -n "$xdotool_bin" ]] || xdotool_bin=/usr/bin/xdotool
  ysock="$(resolve_ydotool_socket)"

  case "$backend" in
    ydotool)
      if [[ ! -S "$ysock" ]]; then
        log "ydotool selected but socket missing: $ysock"
        return 4
      fi
      YDOTOOL_SOCKET="$ysock" "$ydotool_bin" type --key-delay 1 -- "$text"
      ;;
    wtype)
      "$wtype_bin" "$text"
      ;;
    xdotool)
      "$xdotool_bin" type --clearmodifiers --delay 1 -- "$text"
      ;;
    none)
      return 2
      ;;
    *)
      log "Unknown TYPE_BACKEND: $backend"
      return 3
      ;;
  esac
}

paste_text() {
  local desktop_file="$1"
  local resource_class="$2"
  local caption="$3"
  local backend shortcut ydotool_bin xdotool_bin ysock
  backend="$(detect_type_backend)"
  shortcut="$(choose_paste_shortcut "$desktop_file" "$resource_class" "$caption")"
  ydotool_bin="$(command -v ydotool 2>/dev/null || true)"
  xdotool_bin="$(command -v xdotool 2>/dev/null || true)"
  [[ -n "$ydotool_bin" ]] || ydotool_bin=/usr/bin/ydotool
  [[ -n "$xdotool_bin" ]] || xdotool_bin=/usr/bin/xdotool
  ysock="$(resolve_ydotool_socket)"

  case "$backend" in
    ydotool)
      if [[ ! -S "$ysock" ]]; then
        log "ydotool selected but socket missing: $ysock"
        return 4
      fi
      case "$shortcut" in
        ctrl-v)
          YDOTOOL_SOCKET="$ysock" "$ydotool_bin" key 29:1 47:1 47:0 29:0
          ;;
        ctrl-shift-v)
          YDOTOOL_SOCKET="$ysock" "$ydotool_bin" key 29:1 42:1 47:1 47:0 42:0 29:0
          ;;
        shift-insert)
          YDOTOOL_SOCKET="$ysock" "$ydotool_bin" key 42:1 110:1 110:0 42:0
          ;;
        *)
          log "Unknown paste shortcut: $shortcut"
          return 5
          ;;
      esac
      ;;
    xdotool)
      case "$shortcut" in
        ctrl-v) "$xdotool_bin" key --clearmodifiers ctrl+v ;;
        ctrl-shift-v) "$xdotool_bin" key --clearmodifiers ctrl+shift+v ;;
        shift-insert) "$xdotool_bin" key --clearmodifiers Shift+Insert ;;
        *) log "Unknown paste shortcut: $shortcut"; return 5 ;;
      esac
      ;;
    *)
      return 6
      ;;
  esac
}

insert_text() {
  local text="$1"
  local rc=0

  copy_text "$text"

  if [[ "$INSERT_MODE" != "type" ]]; then
    echo "Copied to clipboard."
    return 0
  fi

  sleep 0.12

  if ! focus_is_safe; then
    notify-send "HermesKey" "Focus changed. Transcript copied to clipboard only." || true
    echo "Copied to clipboard (focus changed)."
    return 0
  fi

  load_target_app

  if app_matches_patterns "$PASTE_FOR_APPS" "$TARGET_DESKTOP_FILE" "$TARGET_RESOURCE_CLASS" "$TARGET_CAPTION"; then
    if paste_text "$TARGET_DESKTOP_FILE" "$TARGET_RESOURCE_CLASS" "$TARGET_CAPTION"; then
      log "Pasted transcription into active app (${#text} chars)."
      echo "Pasted into active app."
      return 0
    fi
    rc=$?
  else
    if type_text "$text"; then
      log "Typed transcription into active app (${#text} chars)."
      echo "Typed into active app."
      return 0
    fi
    rc=$?
  fi

  case "$rc" in
    4)
      log "ydotool is installed but ydotoold is not running."
      notify-send "HermesKey" "ydotool is installed, but ydotoold is not running." || true
      echo "Copied to clipboard (ydotoold not running)."
      ;;
    5|6)
      log "Paste fallback is not available for this backend."
      notify-send "HermesKey" "Paste fallback unavailable for this typing backend." || true
      echo "Copied to clipboard (paste fallback unavailable)."
      ;;
    2|3)
      log "No supported typing backend found for active app insertion."
      notify-send "HermesKey" "No typing backend found. Install ydotool, wtype, or xdotool." || true
      echo "Copied to clipboard (typing backend missing)."
      ;;
    *)
      log "Active app insertion failed with code $rc."
      notify-send "HermesKey" "Typing failed. Transcript copied to clipboard." || true
      echo "Copied to clipboard (typing failed)."
      ;;
  esac
  return 0
}

ensure_server() {
  if server_ping; then
    return 0
  fi

  rm -f "$SOCK"
  log "Starting STT server (model=$MODEL lang=$STT_LANG)"
  nohup "$PYTHON_STT" "$SERVER_SCRIPT" --socket "$SOCK" --model "$MODEL" --lang "$STT_LANG" >>"$SERVER_LOG" 2>&1 &
  echo $! >"$SERVER_PID"

  for _ in {1..120}; do
    if server_ping; then
      log "STT server ready"
      return 0
    fi
    sleep 0.25
  done

  log "STT server failed to start"
  notify-send "HermesKey" "Speech model failed to start" || true
  return 1
}

record_start() {
  rm -f "$WAV" 2>/dev/null || true

  ensure_server
  if [[ "$FOCUS_SAFE_MODE" == "1" ]]; then
    capture_target_app
  fi
  play_tone "$START_TONE_HZ"
  show_overlay recording

  log "Starting recording from: $RECORD_SOURCE -> $WAV"
  ffmpeg -y \
    -f pulse -i "$RECORD_SOURCE" \
    -ac 1 -ar 16000 \
    -loglevel error \
    "$WAV" &
  echo $! >"$STATE"
  log "ffmpeg pid: $(cat "$STATE")"
}

request_transcription() {
  REQUEST_WAV="$WAV" REQUEST_LANG="$STT_LANG" REQUEST_SOCK="$SOCK" python3 - <<'PY'
import json
import os
import socket

sock_path = os.environ["REQUEST_SOCK"]
request = {
    "cmd": "transcribe",
    "wav": os.environ["REQUEST_WAV"],
    "language": os.environ["REQUEST_LANG"],
}

with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
    client.connect(sock_path)
    client.sendall((json.dumps(request, ensure_ascii=False) + "\n").encode("utf-8"))
    chunks = []
    while True:
        chunk = client.recv(65536)
        if not chunk:
            break
        chunks.append(chunk)

print(b"".join(chunks).decode("utf-8"), end="")
PY
}

extract_text() {
  python3 -c '
import json, sys
raw = sys.stdin.read().strip()
if not raw:
    sys.exit(2)
reply = json.loads(raw)
if reply.get("status") != "ok":
    print(reply.get("error", "transcription failed"), file=sys.stderr)
    sys.exit(1)
print(reply.get("text", ""), end="")
'
}

record_stop_and_transcribe() {
  if [[ ! -f "$STATE" ]]; then
    echo "Not recording."
    log "Stop requested but no $STATE found"
    hide_overlay
    return
  fi

  local pid
  pid="$(cat "$STATE")"
  log "Stopping ffmpeg pid: $pid"

  if kill -0 "$pid" 2>/dev/null; then
    kill "$pid" 2>/dev/null || true
    for _ in {1..40}; do
      if ! kill -0 "$pid" 2>/dev/null; then
        break
      fi
      sleep 0.05
    done
  fi
  rm -f "$STATE"
  play_tone "$STOP_TONE_HZ"

  for _ in {1..40}; do
    if [[ -s "$WAV" ]]; then
      break
    fi
    sleep 0.05
  done

  if [[ ! -s "$WAV" ]]; then
    hide_overlay
    log "WAV missing or empty: $WAV"
    echo -n "" | "$CLIP_CMD" || true
    notify-send "HermesKey" "No audio captured" || true
    echo "No audio captured."
    return
  fi

  log "WAV size: $(stat -c%s "$WAV" 2>/dev/null || echo '?') bytes"
  show_overlay transcribing

  ensure_server

  local reply transcription
  if ! reply="$(request_transcription 2>>"$LOG")"; then
    hide_overlay
    log "Failed talking to STT server"
    notify-send "HermesKey" "Could not reach speech server" || true
    echo "Transcription failed."
    return
  fi

  if ! transcription="$(printf '%s' "$reply" | extract_text 2>>"$LOG")"; then
    hide_overlay
    log "STT server returned an error"
    notify-send "HermesKey" "Speech transcription failed" || true
    echo "Transcription failed."
    return
  fi

  hide_overlay

  if [[ -z "$transcription" ]]; then
    log "No transcription text produced."
    echo -n "" | "$CLIP_CMD" || true
    echo "No transcription."
    return
  fi

  insert_text "$transcription"
}

if [[ -f "$STATE" ]]; then
  record_stop_and_transcribe
else
  record_start
  echo "Recording... press hotkey again to stop."
fi
