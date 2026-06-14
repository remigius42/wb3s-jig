<!-- spellchecker:ignore cgal commitlint cspell gitleaks markdownlint mdformat pipx -->

# Developing

Contributor setup for this repo. End-user docs are in [`README.md`](./README.md);
agent/design notes are in [`AGENTS.md`](./AGENTS.md).

## Prerequisites

- [`pre-commit`](https://pre-commit.com/) — `pipx install pre-commit` (or
  `pip install --user pre-commit`).
- [OpenSCAD](https://openscad.org/) on `PATH` — needed for the render gate and
  to build the STL.
- Node.js — the `cspell`, `markdownlint`, and `commitlint` hooks fetch their
  tools automatically; no manual install needed.

## One-time hook install

```sh
pre-commit install --hook-type pre-commit --hook-type commit-msg
```

This wires up two stages:

- **pre-commit** — formatting/linting: `mdformat`, `markdownlint`, `cspell`,
  `gitleaks`, whitespace/EOF fixers, and `openscad-render` (renders
  `wb3s_jig.scad` and fails on any CGAL warning/error — see
  [`AGENTS.md`](./AGENTS.md) for what a clean render looks like; only runs when
  a `.scad` file is staged).
- **commit-msg** — `commitlint` enforces
  [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`,
  `fix:`, `chore:`, `docs:` …).

## Everyday use

Hooks run automatically on `git commit` / `git push`. To run them by hand:

```sh
pre-commit run --all-files   # everything, including the render gate
```

Update hook versions with `pre-commit autoupdate`.

## Spell-check

`cspell` reads [`.cspell.yaml`](./.cspell.yaml). For a word that's local to one
file, prefer an inline directive over the global list:

```text
<!-- spellchecker:ignore someword another -->   # in Markdown
// spellchecker:ignore someword another          # in .scad
```

## Verify a geometry change

```sh
openscad -o /tmp/out.stl --render=true wb3s_jig.scad 2>&1 | grep -iE 'warning|error'
```

Clean = no output. This is exactly what the pre-push hook runs.
