# Setup & Updates

## Install

```bash
git clone https://github.com/snowarch/quickshell-ii-niri.git
cd quickshell-ii-niri
./setup install
```

Add `-y` for non-interactive mode.

## Update

```bash
git pull
./setup update
```

Updates QML code, restarts the shell, and offers pending migrations.

## Doctor

```bash
./setup doctor
```

Diagnoses and **automatically fixes** common issues:
- Missing directories
- Script permissions
- Python packages (via uv)
- Version tracking
- File manifest

## Commands

| Command | Description |
|---------|-------------|
| `./setup` | Interactive menu |
| `./setup install` | Full installation |
| `./setup update` | Update + restart shell |
| `./setup doctor` | Diagnose and fix |

Options: `-y` (skip prompts), `-q` (quiet), `-h` (help)

## What Gets Installed

| Source | Destination |
|--------|-------------|
| QML code | `~/.config/quickshell/ii/` |
| Niri config | `~/.config/niri/config.kdl` |
| ii config | `~/.config/illogical-impulse/config.json` |
| GTK/Qt themes | `~/.config/gtk-*/`, `~/.config/kdeglobals` |

On first install, existing configs are backed up. On updates, your configs are never touched - only QML code is synced.

## Migrations

Some features need config changes (new keybinds, layer rules, etc). After `update`, you're asked if you want to apply pending migrations. Each shows exactly what will change, with automatic backup.

## Backups

- Install backups: `~/ii-niri-backup/`
- Update backups: `~/.local/state/quickshell/backups/`

## Uninstall

```bash
# Stop ii from starting
# Comment out in ~/.config/niri/config.kdl:
# spawn-at-startup "qs" "-c" "ii"

# Remove configs
rm -rf ~/.config/quickshell/ii
rm -rf ~/.config/illogical-impulse
```
