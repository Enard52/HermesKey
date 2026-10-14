#!/usr/bin/env python3
import sys
from PySide6.QtCore import Qt
from PySide6.QtGui import QColor, QFont, QPainter
from PySide6.QtWidgets import QApplication, QLabel, QHBoxLayout, QWidget

MODES = {
    "recording": {"text": "Recording", "dot": "#ff4d4f"},
    "transcribing": {"text": "Transcribing", "dot": "#ffb020"},
}


class Dot(QWidget):
    def __init__(self, color: str):
        super().__init__()
        self.color = QColor(color)
        self.setFixedSize(18, 18)

    def paintEvent(self, _event):
        painter = QPainter(self)
        painter.setRenderHint(QPainter.Antialiasing)
        painter.setPen(Qt.NoPen)
        painter.setBrush(self.color)
        painter.drawEllipse(1, 1, 16, 16)


class Overlay(QWidget):
    def __init__(self, mode: str):
        super().__init__()
        cfg = MODES.get(mode, MODES["recording"])

        self.setWindowFlags(
            Qt.Tool
            | Qt.FramelessWindowHint
            | Qt.WindowStaysOnTopHint
            | Qt.BypassWindowManagerHint
            | Qt.WindowDoesNotAcceptFocus
        )
        self.setAttribute(Qt.WA_TranslucentBackground)
        self.setAttribute(Qt.WA_ShowWithoutActivating)
        self.setAttribute(Qt.WA_TransparentForMouseEvents)
        self.setFocusPolicy(Qt.NoFocus)

        wrap = QWidget(self)
        wrap.setObjectName("wrap")
        wrap.setStyleSheet(
            "#wrap {"
            "background-color: rgba(24, 24, 28, 230);"
            "border: 1px solid rgba(255,255,255,40);"
            "border-radius: 14px;"
            "}"
            "QLabel { color: white; }"
        )

        layout = QHBoxLayout(wrap)
        layout.setContentsMargins(14, 10, 14, 10)
        layout.setSpacing(10)

        layout.addWidget(Dot(cfg["dot"]))

        label = QLabel(cfg["text"])
        font = QFont()
        font.setPointSize(12)
        font.setBold(True)
        label.setFont(font)
        layout.addWidget(label)

        outer = QHBoxLayout(self)
        outer.setContentsMargins(0, 0, 0, 0)
        outer.addWidget(wrap)

        self.adjustSize()
        screen = QApplication.primaryScreen().availableGeometry()
        x = screen.x() + (screen.width() - self.width()) // 2
        y = screen.y() + 48
        self.move(x, y)


if __name__ == "__main__":
    app = QApplication(sys.argv)
    mode = sys.argv[1] if len(sys.argv) > 1 else "recording"
    overlay = Overlay(mode)
    overlay.show()
    raise SystemExit(app.exec())
