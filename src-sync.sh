#!/bin/bash
# ============================================================
# ARA TM — src folder ⇄ GitHub sync (backup + restore)
# Developer / توسعه‌دهنده: Parham_7991
# ============================================================
# Keeps /root/src backed up to a PRIVATE GitHub repo (prefix: ara-tm-src-)
# so your work survives Railway container rebuilds.
#
#   src-sync            push now (backup)
#   src-sync --watch    loop push every SYNC_INTERVAL sec (default 180)
#   src-sync --restore  pull from GitHub into /root/src
#   src-sync --init     (re)create the repo + link /root/src
#   src-sync --status   show linked repo + last commit
#
# Env: GITHUB_TOKEN (repo scope) required.
#      SYNC_INTERVAL (sec, default 180) · GITHUB_SYNC_NAME/EMAIL (commit author)
# ============================================================
set -u

SRC=/root/src
STATE=/var/lib/ara
MARK="$STATE/src-repo"          # remembers the chosen repo name
API=https://api.github.com
TOKEN="${GITHUB_TOKEN:-}"
INTERVAL="${SYNC_INTERVAL:-180}"

die()  { echo "src-sync: $*" >&2; exit 1; }
need() { [ -n "$TOKEN" ] || die "GITHUB_TOKEN not set — cannot sync /root/src"; }

git_ident() {
  git config --global user.email "${GITHUB_SYNC_EMAIL:-sync@ara.tm}" 2>/dev/null
  git config --global user.name  "${GITHUB_SYNC_NAME:-ARA TM Sync}" 2>/dev/null
  git config --global init.defaultBranch main 2>/dev/null
  git config --global push.autoSetupRemote true 2>/dev/null
}

# deterministic, restorable repo name with the ARA TM prefix
repo_name() {
  [ -f "$MARK" ] && { cat "$MARK"; return; }
  local id="${RAILWAY_PROJECT_ID:-}"
  [ -z "$id" ] && id="$(hostname)"
  echo "$id" | tr -c 'A-Za-z0-9' '-' | tr '[:upper:]' '[:lower:]' | cut -c1-40 \
    | sed 's/-*$//' | sed 's/^/ara-tm-src-/'
}

gh_user() {
  curl -s --max-time 12 -H "Authorization: Bearer $TOKEN" "$API/user" \
    | jq -r '.login // empty' 2>/dev/null
}

repo_exists() {
  local u="$1" n="$2"
  curl -s --max-time 12 -H "Authorization: Bearer $TOKEN" "$API/repos/$u/$n" \
    | jq -r '.id // empty' 2>/dev/null
}

create_repo() {
  local n="$1"
  curl -s --max-time 20 -X POST "$API/user/repos" \
    -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
    -d "{\"name\":\"$n\",\"private\":true,\"description\":\"ARA TM cloud workspace — auto-synced src folder\",\"auto_init\":false}" \
    | jq -r '.id // empty' 2>/dev/null
}

remote_url() { echo "https://$TOKEN@github.com/$1/$2.git"; }

# resolve the linked repo (name stored, else by RAILWAY_PROJECT_ID, else by prefix)
resolve_name() {
  [ -f "$MARK" ] && { cat "$MARK"; return; }
  local id; id=$(repo_name | sed 's/^ara-tm-src-//')
  local u; u=$(gh_user); [ -n "$u" ] || return 1
  local found
  found=$(curl -s --max-time 12 -H "Authorization: Bearer $TOKEN" \
    "$API/user/repos?per_page=100&affiliation=owner" \
    | jq -r --arg p "ara-tm-src-$id" --arg px "ara-tm-src-" \
      '.[] | select(.name==$p or (.name|startswith($px))) | .name' 2>/dev/null | head -1)
  echo "${found:-ara-tm-src-$id}"
}

do_init() {
  need; git_ident; mkdir -p "$SRC"
  local name; name=$(resolve_name); echo "$name" > "$MARK"
  local u; u=$(gh_user); [ -n "$u" ] || die "cannot read GitHub user from token"
  if [ -z "$(repo_exists "$u" "$name")" ]; then
    create_repo "$name" >/dev/null && echo "created repo $u/$name" \
      || die "failed to create repo $u/$name (check token scope = repo)"
  else
    echo "repo $u/$name already exists"
  fi
  if [ ! -d "$SRC/.git" ]; then git -C "$SRC" init -q; fi
  git -C "$SRC" remote set-url origin "$(remote_url "$u" "$name")" 2>/dev/null \
    || git -C "$SRC" remote add origin "$(remote_url "$u" "$name")"
  echo "$u/$name"
}

do_restore() {
  need; git_ident
  [ -d "$SRC/.git" ] && { git -C "$SRC" pull --ff-only 2>/dev/null && return 0; }
  local name; name=$(resolve_name) || die "cannot resolve repo name"
  local u; u=$(gh_user); [ -n "$u" ] || die "cannot read GitHub user"
  [ -z "$(repo_exists "$u" "$name")" ] \
    && { echo "no repo $u/$name yet — will create on first push"; return 0; }
  echo "$name" > "$MARK"
  if [ -d "$SRC/.git" ]; then
    git -C "$SRC" remote set-url origin "$(remote_url "$u" "$name")"
    git -C "$SRC" pull --ff-only 2>/dev/null
  elif [ -z "$(ls -A "$SRC" 2>/dev/null)" ]; then
    git clone "$(remote_url "$u" "$name")" "$SRC" 2>&1 | tail -2
  else
    mv "$SRC" "${SRC}.local"
    git clone "$(remote_url "$u" "$name")" "$SRC" 2>&1 | tail -2
    cp -a "${SRC}.local"/. "$SRC"/ 2>/dev/null; rm -rf "${SRC}.local"
  fi
}

do_push() {
  need
  [ -d "$SRC/.git" ] || do_init >/dev/null
  git_ident
  git -C "$SRC" add -A
  git -C "$SRC" diff --cached --quiet && { echo "src: nothing to sync"; return 0; }
  git -C "$SRC" commit -q -m "auto-sync $(date -u +%Y-%m-%dT%H:%M:%SZ)" 2>/dev/null
  git -C "$SRC" pull --rebase --autostash 2>/dev/null || true
  git -C "$SRC" push -u origin HEAD 2>&1 | tail -3
}

do_watch() {
  need
  echo "src-sync: watching $SRC every ${INTERVAL}s"
  while true; do do_push >/dev/null 2>&1; sleep "$INTERVAL"; done
}

do_status() {
  need
  local name; name=$(resolve_name) || die "cannot resolve repo name"
  local u; u=$(gh_user)
  echo "SRC:    $SRC"
  echo "Repo:   ${u:-(unknown)}/$name"
  echo "Remote: $(git -C "$SRC" remote get-url origin 2>/dev/null || echo '(not linked)')"
  echo "Last:   $(git -C "$SRC" log -1 --format='%h %cr %s' 2>/dev/null || echo '(no commits)')"
}

case "${1:-push}" in
  --init)    do_init ;;
  --restore) do_restore ;;
  --watch)   do_watch ;;
  --status)  do_status ;;
  push|--push) do_push ;;
  *) echo "usage: src-sync [--init|--restore|--watch|--status|push]"; exit 1 ;;
esac
