#!/bin/bash
# ============================================================
# ARA TM — Fancy SSH login banner / بنر ورود SSH زیبای ARA TM
# Developer / توسعه‌دهنده: Parham_7991
# ============================================================
# Shown on interactive SSH login. Fully self-contained: gathers system
# info by hand so every line is under our control (no neofetch --exec).
# هنگام ورود تعاملی SSH نمایش داده می‌شود و اطلاعات سیستم را خودش جمع می‌کند.

# Only run for interactive terminals / فقط برای ترمینال تعاملی
[ -t 1 ] || return 0 2>/dev/null || exit 0

# ---- Colors / رنگ‌ها ----
C_RESET=$'\e[0m'; C_BOLD=$'\e[1m'; C_DIM=$'\e[2m'
C_CYAN=$'\e[38;5;51m'; C_BLUE=$'\e[38;5;33m'; C_PURPLE=$'\e[38;5;135m'
C_GREEN=$'\e[38;5;46m'; C_YELLOW=$'\e[38;5;220m'; C_GREY=$'\e[38;5;245m'
C_RED=$'\e[38;5;196m'; C_WHITE=$'\e[38;5;231m'

# ---- Gather system info / جمع‌آوری اطلاعات سیستم ----
_os="$( . /etc/os-release 2>/dev/null; echo "${PRETTY_NAME:-Linux}" )"
_kernel="$(uname -r 2>/dev/null)"
_host="$(hostname 2>/dev/null)"
_user="$(whoami 2>/dev/null)"
_uptime="$(uptime -p 2>/dev/null | sed 's/^up //')"; : "${_uptime:=just now}"
_cpu="$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2 | sed 's/^ *//; s/  */ /g')"
_cores="$(nproc 2>/dev/null)"; : "${_cpu:=CPU}"
_mem="$(free -h 2>/dev/null | awk '/^Mem:/ {print $3 " / " $2}')"
_disk="$(df -h / 2>/dev/null | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')"
_ip="$(hostname -I 2>/dev/null | awk '{print $1}')"; : "${_ip:=n/a}"
if command -v claude >/dev/null 2>&1; then
  _claude="${C_GREEN}● ready${C_RESET}"
else
  _claude="${C_RED}● not installed${C_RESET}"
fi

# ---- Render / نمایش ----
printf '\n'
printf '%s\n' "${C_CYAN}${C_BOLD}   █████╗ ██████╗  █████╗     ████████╗███╗   ███╗${C_RESET}"
printf '%s\n' "${C_CYAN}${C_BOLD}  ██╔══██╗██╔══██╗██╔══██╗    ╚══██╔══╝████╗ ████║${C_RESET}"
printf '%s\n' "${C_BLUE}${C_BOLD}  ███████║██████╔╝███████║       ██║   ██╔████╔██║${C_RESET}"
printf '%s\n' "${C_BLUE}${C_BOLD}  ██╔══██║██╔══██╗██╔══██║       ██║   ██║╚██╔╝██║${C_RESET}"
printf '%s\n' "${C_PURPLE}${C_BOLD}  ██║  ██║██║  ██║██║  ██║       ██║   ██║ ╚═╝ ██║${C_RESET}"
printf '%s\n' "${C_PURPLE}${C_BOLD}  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═╝   ╚═╝     ╚═╝${C_RESET}"
printf '\n'
printf '%s\n' "${C_WHITE}${C_BOLD}          ☁  Cloud Shell · Railway Ubuntu  🚂${C_RESET}"
printf '%s\n' "${C_YELLOW}${C_BOLD}               Developer · Parham_7991${C_RESET}"
printf '\n'

# Divider / خط‌جدا‌کننده
line="${C_GREY}  ────────────────────────────────────────────────${C_RESET}"
printf '%s\n' "$line"

row() { printf "  ${C_CYAN}%s${C_RESET} ${C_DIM}%s${C_RESET} %b\n" "$1" "$2" "$3"; }
row " User    " "│" "${C_WHITE}${_user}${C_RESET}${C_GREY} @ ${C_WHITE}${_host}${C_RESET}"
row " OS      " "│" "${C_WHITE}${_os}${C_RESET}"
row " Kernel  " "│" "${C_WHITE}${_kernel}${C_RESET}"
row " Uptime  " "│" "${C_WHITE}${_uptime}${C_RESET}"
row " CPU     " "│" "${C_WHITE}${_cpu} ${C_GREY}(${_cores} cores)${C_RESET}"
row " Memory  " "│" "${C_WHITE}${_mem}${C_RESET}"
row " Disk    " "│" "${C_WHITE}${_disk}${C_RESET}"
row " IP      " "│" "${C_WHITE}${_ip}${C_RESET}"
row " Claude  " "│" "${_claude}"

# src ⇄ GitHub sync status (reads the local repo mark; no network call)
# وضعیت همگام‌سازی src با GitHub (نشانگر محلی مخزن را می‌خواند؛ بدون فراخوانی شبکه)
if [ -n "${GITHUB_TOKEN:-}" ] && [ -f /var/lib/ara/src-repo ]; then
  _repo="$(cat /var/lib/ara/src-repo 2>/dev/null)"
  _src="${C_GREEN}● synced → ${C_RESET}${C_WHITE}${_repo}${C_RESET}"
else
  _src="${C_GREY}● off — set GITHUB_TOKEN to backup${C_RESET}"
fi
row " src     " "│" "${_src}"

printf '%s\n' "$line"
printf "  ${C_GREEN}➜${C_RESET} ${C_DIM}Run${C_RESET} ${C_YELLOW}${C_BOLD}cl${C_RESET} ${C_DIM}(or ${C_RESET}${C_YELLOW}${C_BOLD}زم${C_RESET}${C_DIM}) to launch Claude Code in tmux${C_RESET}\n"
printf "  ${C_GREEN}➜${C_RESET} ${C_DIM}Run${C_RESET} ${C_YELLOW}${C_BOLD}usage${C_RESET} ${C_DIM}to check Railway trial credit & uptime left${C_RESET}\n"
printf "  ${C_GREEN}➜${C_RESET} ${C_DIM}Run${C_RESET} ${C_YELLOW}${C_BOLD}src-sync --status${C_RESET} ${C_DIM}to see your private backup repo${C_RESET}\n"
printf '\n'
