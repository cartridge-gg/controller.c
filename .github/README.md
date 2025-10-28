# GitHub Workflows

This directory contains CI/CD workflows for the controller.c project.

## Workflows

### 🔄 rust-ci.yml
**Triggered on:** Every push and PR to main/develop branches

**Jobs:**
- **fmt**: Checks code formatting with `rustfmt`
- **clippy**: Runs linter checks with `clippy`
- **test**: Runs the test suite
- **build**: Builds on Ubuntu and macOS
- **build-ios**: Builds for iOS device and simulator targets
- **security-audit**: Runs `cargo audit` for security vulnerabilities

### 🌙 rust-nightly.yml
**Triggered on:** Daily at midnight UTC (or manual trigger)

**Jobs:**
- **check-nightly**: Tests compatibility with Rust nightly
- **outdated-deps**: Checks for outdated dependencies

### 📚 rust-doc.yml
**Triggered on:** Push/PR to main branch

**Jobs:**
- **doc**: Builds documentation and checks for broken links

### 🤖 dependabot.yml
**Automated dependency updates** for:
- Cargo dependencies (weekly)
- GitHub Actions (weekly)

## Configuration Files

### rustfmt.toml
Rust formatting configuration:
- Edition: 2021
- Max width: 100 characters
- Unix newlines
- Auto-reorder imports

### PULL_REQUEST_TEMPLATE.md
Standard PR template for contributors

## Status Badges

Add these to your README.md:

```markdown
![Rust CI](https://github.com/cartridge-gg/controller.c/workflows/Rust%20CI/badge.svg)
![Nightly Checks](https://github.com/cartridge-gg/controller.c/workflows/Rust%20Nightly%20Checks/badge.svg)
![Documentation](https://github.com/cartridge-gg/controller.c/workflows/Documentation/badge.svg)
```

## Local Development

### Format code
```bash
cargo fmt
```

### Run clippy
```bash
cargo clippy --all-targets --all-features -- -D warnings
```

### Run tests
```bash
cargo test --all
```

### Build documentation
```bash
cargo doc --no-deps --all-features --open
```

### Security audit
```bash
cargo install cargo-audit
cargo audit
```

## GitHub Actions Cache

All workflows use caching for:
- Cargo registry (`~/.cargo/registry`)
- Cargo git index (`~/.cargo/git`)
- Build artifacts (`target/`)

This significantly speeds up CI runs.

## Required Secrets

None currently required. All workflows run with default permissions.

## Customization

To customize workflows:
1. Edit the relevant `.yml` file in `.github/workflows/`
2. Adjust the `rustfmt.toml` for formatting preferences
3. Update `dependabot.yml` for dependency update frequency

## Troubleshooting

**Workflow fails on fmt?**
```bash
cargo fmt --all
git add .
git commit -m "Format code"
```

**Workflow fails on clippy?**
```bash
cargo clippy --all-targets --all-features --fix
git add .
git commit -m "Fix clippy warnings"
```

**iOS build fails?**
Make sure targets are installed:
```bash
rustup target add aarch64-apple-ios
rustup target add aarch64-apple-ios-sim
```

