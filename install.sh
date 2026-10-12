#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
usage: install.sh [--apply] [--render-only] [--overlay FILE]

Links mstack into Claude Code, Codex, pi, Devin, and Cursor. Prints the plan and changes nothing unless --apply is given.

  --apply         make the changes
  --render-only   only write ~/.config/mstack/AGENTS.md (use when home-manager owns the links)
  --overlay FILE  private rules appended after the core AGENTS.md
                  (default: $MSTACK_OVERLAY, else ~/.config/mstack/overlay.md if it exists)

Safe to rerun. It never overwrites, moves, or deletes a file it did not create.
EOF
}

apply=0
render_only=0
overlay="${MSTACK_OVERLAY:-}"

while [ $# -gt 0 ]; do
  case "$1" in
    --apply) apply=1 ;;
    --render-only) render_only=1 ;;
    --overlay) overlay="${2:?--overlay needs a file}"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "install.sh: unknown argument '$1'" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

mstack_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
out_dir="${XDG_CONFIG_HOME:-$HOME/.config}/mstack"
rendered="$out_dir/AGENTS.md"
marker="$out_dir/.rendered-by-mstack"
codex_home="${CODEX_HOME:-$HOME/.codex}"

if [ -z "$overlay" ] && [ -f "$out_dir/overlay.md" ]; then
  overlay="$out_dir/overlay.md"
fi
if [ -n "$overlay" ] && [ ! -f "$overlay" ]; then
  echo "install.sh: overlay '$overlay' is not a file" >&2
  exit 2
fi

say() { printf '%s\n' "$*"; }

run() {
  if [ "$apply" -eq 1 ]; then
    "$@"
  fi
}

owned_by_mstack() {
  [ ! -e "$rendered" ] && [ ! -L "$rendered" ] && return 0
  [ -L "$rendered" ] && [ "$(readlink "$rendered")" = "$mstack_dir/AGENTS.md" ] && return 0
  [ -e "$marker" ]
}

render() {
  if ! owned_by_mstack; then
    say "skip    $rendered exists and was not written by mstack. Move it aside, then rerun."
    return
  fi
  run mkdir -p "$out_dir"
  if [ -z "$overlay" ]; then
    if [ -L "$rendered" ] && [ "$(readlink "$rendered")" = "$mstack_dir/AGENTS.md" ]; then
      say "ok      $rendered -> $mstack_dir/AGENTS.md"
      return
    fi
    say "link    $rendered -> $mstack_dir/AGENTS.md (no overlay, edits are live)"
    run ln -sfn "$mstack_dir/AGENTS.md" "$rendered"
    run touch "$marker"
    return
  fi
  say "render  $rendered = $mstack_dir/AGENTS.md + $overlay (rerun after editing either)"
  if [ "$apply" -eq 1 ]; then
    tmp="$(mktemp "$out_dir/.AGENTS.md.XXXXXX")"
    { cat "$mstack_dir/AGENTS.md"; printf '\n'; cat "$overlay"; } > "$tmp"
    mv -f "$tmp" "$rendered"
    touch "$marker"
  fi
}

link() {
  target="$1"
  dest="$2"
  if [ -L "$dest" ]; then
    current="$(readlink "$dest")"
    if [ "$current" = "$target" ]; then
      say "ok      $dest"
    elif case "$current" in /nix/store/*) true ;; *) false ;; esac; then
      say "skip    $dest is managed by home-manager. Point it at $target in home.nix."
    else
      say "skip    $dest already links to $current. Remove that link yourself, then rerun."
    fi
    return
  fi
  if [ -e "$dest" ]; then
    say "skip    $dest exists. Move it aside yourself, then rerun."
    return
  fi
  say "link    $dest -> $target"
  run mkdir -p "$(dirname "$dest")"
  run ln -s "$target" "$dest"
}

[ "$apply" -eq 1 ] || say "Dry run. Nothing changes until you pass --apply."

render

if [ "$render_only" -eq 1 ]; then
  exit 0
fi

link "$rendered" "$HOME/.claude/CLAUDE.md"
link "$rendered" "$codex_home/AGENTS.md"
link "$rendered" "$HOME/.pi/agent/AGENTS.md"
link "$rendered" "$HOME/.config/devin/AGENTS.md"

for skill_dir in "$mstack_dir"/skills/*/; do
  name="$(basename "$skill_dir")"
  link "$mstack_dir/skills/$name" "$HOME/.agents/skills/$name"
  link "$HOME/.agents/skills/$name" "$HOME/.claude/skills/$name"
done

link "$mstack_dir/bin/check-comments" "$HOME/.local/bin/check-comments"

say "manual  Cursor keeps user rules only in Customize > Rules. Paste $rendered there after each change."
