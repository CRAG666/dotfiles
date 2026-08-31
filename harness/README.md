# AI harness configs

Configs for the AI coding harnesses, installed with `just harness`
(also pulled in by `just init`).

| Directory  | Install target       | Method                          |
| ---------- | -------------------- | ------------------------------- |
| `pi/`      | `~/.pi/agent/`       | symlinks (per file) + copy of `settings.json` |
| `claude/`  | `~/.claude/`         | symlinks (per file) + copy of `settings.json` |
| `opencode/`| `~/.config/opencode/`| per-file symlinks (config only)     |

Plus `skills/` (repo root) linked into `~/.agents/skills`, shared by pi and
claude (`~/.claude/skills` → `~/.agents/skills`). Each harness also carries
its `themes/` (eyes light/dark variants); `just harness` links them into the
live theme dirs and `.scripts/eyes-theme` flips the active one.

## Why copies instead of symlinks for settings.json

Both pi and `eyes-theme` rewrite `settings.json` in place: pi updates
`lastChangelogVersion`, and `.scripts/eyes-theme` flips the `theme` key with
`jq` + `mv` on every light/dark switch. A symlink would be replaced by those
writes, so these two files install as **copies** (first existing copy is kept
as `settings.json.bak`). Edit them here and re-run `just harness`.

## What stays untracked (machine-local)

- pi: `auth.json`, `models-store.json`, `trust.json`, `sessions/`, `npm/`,
  `extensions/`
- claude: `settings.local.json` (secrets – copy it from
  `settings.local.json.example`), `.credentials.json`, `history.jsonl`,
  `sessions/`, `projects/`
- opencode (runtime, lives only in the real `~/.config/opencode`):
  `node_modules/`, `package*.json` (npm deps for its plugins), `plugins/`,
  `herder-tui-session.js`, `tui.json`, `tui.jsonc`, `.claude/`
- herdr integrations (`~/.claude/hooks/`, `~/.pi/agent/extensions/`,
  `~/.config/opencode/plugins/` and the `hooks` block it ensures in claude's
  `settings.json`): installed and updated by herdr itself
  (`herdr integration install <agent>`), never tracked. `just harness`
  re-runs the installer when herdr is present.
