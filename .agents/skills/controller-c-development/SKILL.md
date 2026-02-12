---
name: controller-c-development
description: Contributor workflow for cartridge-gg/controller.c. Use when implementing or reviewing UniFFI-based multi-language bindings, generated artifacts, and Rust/script validation in this repository.
---

# Controller C Development

Use this skill to update `cartridge-gg/controller.c` bindings safely across supported languages.

## Core Workflow

1. Build the Rust core first:
   - `cargo build --release`
2. Regenerate only affected bindings:
   - `./scripts/build_python.sh`
   - `./scripts/build_swift.sh`
   - `./scripts/build_kotlin.sh`
   - `./scripts/build_cpp.sh`
   - `./scripts/build_csharp.sh`
   - `./scripts/build_go.sh`
3. Run repository checks:
   - `./scripts/fmt.sh`
   - `./scripts/clippy.sh`
   - `./scripts/test.sh`
4. Use `./scripts/check.sh` before PR for a consolidated pass.

## PR Checklist

- Keep generated binding changes synchronized with Rust API updates.
- Call out language targets regenerated in the PR body.
- Include full validation command list and outcomes.
