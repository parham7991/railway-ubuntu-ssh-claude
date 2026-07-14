#!/bin/bash

# ============================================================
# ARA TM — "cl" command: open a tmux session running Claude Code
# Developer / توسعه‌دهنده: Parham_7991
# ============================================================
# Creates a new tmux session named "claude" and runs `claude` inside it.
# If the session already exists, it attaches to it instead.
# یک نشست tmux به نام "claude" می‌سازد و برنامه `claude` را در آن اجرا می‌کند.
# اگر نشست از قبل وجود داشته باشد، به جای ایجاد، به آن متصل می‌شود.

SESSION="claude"

if tmux has-session -t "$SESSION" 2>/dev/null; then
    # Session exists — attach to it / نشست وجود دارد — به آن متصل شو
    tmux attach -t "$SESSION"
else
    # Create a new session and run Claude Code inside it
    # ایجاد نشست جدید و اجرای Claude Code در آن
    tmux new-session -s "$SESSION" "claude"
fi
