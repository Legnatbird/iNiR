# Precompiled Packages Analysis for iNiR

## Executive Summary

**CRITICAL FINDING**: Quickshell and Niri are now in **official Arch Linux repos** (extra).
The installer should use these instead of AUR packages that require compilation.

## Package Availability by Distribution

### Arch Linux (and derivatives)

| Package | Source | Compilation? | Notes |
|---------|--------|--------------|-------|
| `quickshell` | **extra** | ❌ No | v0.2.1-4 - USE THIS |
| `quickshell-git` | AUR | ✅ Yes | ~15 min compile - AVOID |
| `niri` | **extra** | ❌ No | Official package |
| `cliphist` | **extra** | ❌ No | v0.7.0-1 |
| `matugen-bin` | AUR | ❌ No | Binary from GitHub |
| `gum` | **extra** | ❌ No | Official package |
| `xwayland-satellite` | **extra** | ❌ No | Official package |

**Chaotic-AUR** (optional, for faster AUR):
- Pre-built binaries of AUR packages
- Setup: https://aur.chaotic.cx/

### Fedora (and derivatives)

| Package | Source | Compilation? | Notes |
|---------|--------|--------------|-------|
| `quickshell` | **COPR** | ❌ No | `errornointernet/quickshell` |
| `niri` | **COPR** | ❌ No | `yalter/niri` |
| `gum` | GitHub | ❌ No | .rpm from releases |
| `cliphist` | GitHub | ❌ No | Binary from releases |
| `matugen` | GitHub | ❌ No | Binary from releases |
| `darkly` | GitHub | ❌ No | .rpm from releases |

### Debian/Ubuntu

| Package | Source | Compilation? | Notes |
|---------|--------|--------------|-------|
| `quickshell` | Source | ✅ Yes | No prebuilt available |
| `niri` | **PPA** (25.10+) | ❌ No | `avengemedia/danklinux` |
| `niri` | Source (<25.10) | ✅ Yes | cargo build |
| `gum` | GitHub | ❌ No | .deb from releases |
| `cliphist` | GitHub | ❌ No | Binary from releases |
| `matugen` | GitHub | ❌ No | Binary from releases |

## GitHub Release Binaries

Tools with precompiled binaries available:

```bash
# gum (has .deb, .rpm, .tar.gz)
https://github.com/charmbracelet/gum/releases

# cliphist (has linux-amd64 binary)
https://github.com/sentriz/cliphist/releases

# matugen (has x86_64.tar.gz)
https://github.com/InioX/matugen/releases

# darkly (has .deb, .rpm)
https://github.com/Bali10050/darkly/releases

# starship (has installer script)
https://starship.rs/install.sh

# eza (has linux-musl binary)
https://github.com/eza-community/eza/releases

# uv (has installer script)
https://astral.sh/uv/install.sh
```

## Recommended Changes

### 1. Arch Installer (`dist-arch/install-deps.sh`)

**Before:**
```bash
AUR_PACKAGES=(
  quickshell-git      # COMPILES ~15 min
  google-breakpad     # COMPILES
  ...
)
```

**After:**
```bash
# Use official repo packages (NO compilation)
PACMAN_PACKAGES=(
  quickshell          # FROM EXTRA - precompiled!
  niri                # FROM EXTRA - precompiled!
  cliphist            # FROM EXTRA - precompiled!
  gum                 # FROM EXTRA - precompiled!
  xwayland-satellite  # FROM EXTRA - precompiled!
)

AUR_PACKAGES=(
  matugen-bin         # Binary package - no compile
  # Only keep AUR packages that have -bin variants
)
```

### 2. Fedora Installer (`dist-fedora/install-deps.sh`)

Already using COPRs correctly. Minor improvements:
- Verify COPR is enabled before install
- Add fallback to GitHub releases if COPR fails

### 3. Debian Installer (`dist-debian/install-deps.sh`)

- Add PPA support for Ubuntu 25.10+
- Use GitHub release binaries where possible
- Only compile what's absolutely necessary

## Installation Time Comparison

| Distro | Current | With Precompiled |
|--------|---------|------------------|
| Arch | ~20-30 min | **~3-5 min** |
| Fedora | ~5-10 min | ~5-10 min (already good) |
| Debian/Ubuntu | ~45-60 min | ~30-40 min |

## Implementation Priority

1. **HIGH**: Fix Arch installer to use `quickshell` from extra
2. **HIGH**: Add `cliphist` to PKGBUILD depends (it's in extra now)
3. **MEDIUM**: Add Chaotic-AUR setup option for remaining AUR packages
4. **MEDIUM**: Improve GitHub binary download functions
5. **LOW**: Add PPA support for Ubuntu 25.10+
