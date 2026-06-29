# Bun-backed Node

This tap installs `node`, `npm`, and `npx` wrappers that actually execute Bun binaries.

It is intentionally deceptive:

- Node-oriented apps see `node`, `npm`, and `npx` on `PATH`, but they are Bun-backed shims.
- Homebrew sees a formula named `node`, so formulas that depend on `node` can be satisfied by this tap.

The point is to let Bun stand in for Node in environments that only know how to ask for `node`.

## Bun

This tap routes `node`, `npm`, and `npx` to Bun. Read more about Bun at <https://bun.sh/>.

This formula is intentionally `HEAD`-only. It is a shim, not a real Node.js release, so the tap does not publish a fake Node version number.

## Compatibility warning

This is not a real Node.js distribution.

- Bun is not fully compatible with Node.js.
- Some CLIs, build tools, package scripts, and Homebrew formulas that assume real Node behavior may fail.
- If you need predictable upstream Node semantics, install official Homebrew `node` instead.
- If you are evaluating whether this shim fits your workflow, see Bun's docs at <https://bun.sh/>.

## Install

Tap the repository and install `node`:

```sh
brew tap lingyang-kong/node-via-bun
brew install --HEAD lingyang-kong/node-via-bun/node
```

## What it provides

- `node` -> `bun`
- `npm` -> `bun`
- `npx` -> `bunx`

The formula compiles one BusyBox-style C shim during install and hard-links `node`, `npm`, and `npx` to it.

`node`, `npm`, and `npx` pass through to Bun for all commands; `--version`/`-v` is shimmed to return the version aligned with the resolved Bun/Node release mapping.

## Local development

To test the formula from a checked out copy:

```sh
brew tap lingyang-kong/node-via-bun /path/to/homebrew-node-via-bun
brew install --HEAD lingyang-kong/node-via-bun/node
```
