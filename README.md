# mstack

My standard for coding agents: how I want them to work, write code, prove it works, ship PRs, and review. One file, every harness (Claude Code, Codex, pi, Devin, Cursor). The name is a nod to [pstack](https://github.com/cursor/plugins/tree/main/pstack).

## Three layers

| Layer | Where it lives | What goes in it | Who changes it |
|---|---|---|---|
| Core | this repo, `AGENTS.md` | Generic rules that hold in every repo and every harness | Me |
| Repo | each repo's own `AGENTS.md` | Only what is true for that repo: commands, layout, invariants, team rules | The team, through a reviewed PR |
| Overlay | private, outside this repo (for me: `~/nixcfg/home/AGENTS.local.md`) | Machine and personal facts: shell, editor, my orchestration tools | Me |

A repo file adds to the core. If the two disagree about that repo, the repo file wins, except on safety, secrets, and commit identity.

Nothing company-specific and no secret goes in the core.

## What is inside

- `AGENTS.md`: the core rules, always loaded.
- `bin/check-comments`: lists comment and docstring lines a branch adds. The no-comments rule failed as prose, so it has a check.
- `skills/grilling`: `/grilling` interviews me about a plan, one round of questions at a time, each with a recommended answer.
- `skills/correct`: `/correct` turns a mistake I keep correcting into a check, so the next agent cannot repeat it.
- `skills/joe`: `/joe` re-pitches a message that did not land, in plain language.

The three skills load only when typed. They cost no context until then.

The skills live in one shared folder, `~/.agents/skills/`. Codex, pi, Devin, and Cursor read it natively. Claude Code reads only `~/.claude/skills/`, so each skill there is a link back to the shared folder.

| Harness | Global instructions | Skills | Invoke a skill |
|---|---|---|---|
| Claude Code | `~/.claude/CLAUDE.md` | `~/.claude/skills/` (links to `~/.agents/skills/`) | `/grilling` |
| Codex | `~/.codex/AGENTS.md` | `~/.agents/skills/` | `$grilling` |
| pi | `~/.pi/agent/AGENTS.md` | `~/.agents/skills/` | `/skill:grilling` |
| Devin | `~/.config/devin/AGENTS.md` | `~/.agents/skills/` | `/grilling` |
| Cursor | No file. Paste into Customize > Rules > User Rules | `~/.agents/skills/` | `/grilling` |

Notes per harness:

- **Cursor** keeps user rules only in its settings. After each change, paste `~/.config/mstack/AGENTS.md` into Customize > Rules > User Rules. Cursor reads a repo's own `AGENTS.md` natively.
- **Cursor** also reads `~/.claude/skills/` and `~/.codex/skills/` for compatibility, so it may list a skill twice. Both entries are the same files.
- **Devin** also reads `~/.claude/CLAUDE.md` while its Claude import is on (the default), so it may load the rules twice. Set `read_config_from.claude` to `false` in `~/.config/devin/config.json` to load them once.
- **Codex** treats `~/.codex/skills/` as deprecated and reads `~/.agents/skills/`.
- Each skill sets `disable-model-invocation: true` (Claude Code, pi, Cursor), `triggers: [user]` (Devin), and `agents/openai.yaml` (Codex), so it runs only when typed.

## Install

1. Clone this repo, for example to `~/Documents/Github/mstack`.
2. Read `install.sh` before you run it.
3. Run `./install.sh` to see the plan. Nothing changes.
4. Run `./install.sh --apply` to make the links.
5. To add private rules, run `./install.sh --apply --overlay <file>`, or put them in `~/.config/mstack/overlay.md`.

`install.sh` writes `~/.config/mstack/AGENTS.md`: a live link to the core, or the core plus your overlay. Every harness path links to that one file.

With an overlay, rerun `./install.sh --apply` after editing the core or the overlay. Without one, edits to the core are live.

`install.sh` never overwrites, moves, or deletes a file it did not create. It prints `skip` and tells you what to move instead.

## With home-manager

If home-manager already owns the harness links, let it keep them and point them at the rendered file:

```nix
let
  mstack = "${config.home.homeDirectory}/Documents/Github/mstack";
  rendered = "${config.home.homeDirectory}/.config/mstack/AGENTS.md";
  overlay = "${config.home.homeDirectory}/nixcfg/home/AGENTS.local.md";
  link = path: config.lib.file.mkOutOfStoreSymlink path;
in {
  home.file.".claude/CLAUDE.md".source = link rendered;
  home.file.".codex/AGENTS.md".source = link rendered;
  home.file.".pi/agent/AGENTS.md".source = link rendered;
  home.file.".config/devin/AGENTS.md".source = link rendered;
  home.file.".local/bin/check-comments".source = link "${mstack}/bin/check-comments";
  home.file.".agents/skills/grilling".source = link "${mstack}/skills/grilling";
  home.file.".claude/skills/grilling".source = link "${config.home.homeDirectory}/.agents/skills/grilling";

  home.activation.mstackRender = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -x "${mstack}/install.sh" ]; then
      run "${mstack}/install.sh" --apply --render-only --overlay "${overlay}"
    fi
  '';
}
```

Repeat the two skill lines for `correct` and `joe`. The activation step re-renders the file on every switch. Between switches, rerun `install.sh --apply --render-only --overlay <file>` after editing.

## check-comments

```bash
check-comments                       # compare with origin/HEAD, else origin/main
check-comments origin/develop        # compare with another base
check-comments origin/develop -- src # only under src/
```

It reads committed and uncommitted changes since the merge base. It prints `path:line: text` for each added comment or docstring line and exits 1. A clean branch exits 0.

It keeps functional lines: shebangs, encoding and license headers, generated-file headers, `from __future__`, and lint or type pragmas.

## Credits

- `skills/grilling` is adapted from `grilling` in [mattpocock/skills](https://github.com/mattpocock/skills) (MIT, Copyright 2026 Matt Pocock).
- `skills/correct` is adapted from `correct` in [cursor/plugins pstack](https://github.com/cursor/plugins/tree/main/pstack) (MIT, Copyright 2026 Lauren Tan).
- `skills/joe` draws on `wait-what` (Matt Pocock) and pstack `bro`.

mstack is MIT-licensed (`LICENSE`). The upstream MIT notices are in `THIRD_PARTY_NOTICES.md`.
