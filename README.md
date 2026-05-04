<div align="center">
<img src="assets/banner.png" alt="" />

**KDE Plasma Desktop — right inside your Termux.**

[![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?style=flat-square&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-Termux-000000?style=flat-square&logo=android&logoColor=white)](https://termux.dev/)
[![Desktop](https://img.shields.io/badge/Desktop-KDE%20Plasma-1d99f3?style=flat-square&logo=kde&logoColor=white)](https://kde.org/plasma-desktop/)
[![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)
[![Author](https://img.shields.io/badge/by-0xNullGun-ff6b6b?style=flat-square)](https://github.com/0xNullGun)

</div>

---

## ✦ What is TermuxKDE?

**TermuxKDE** is a fully automated installer that sets up a complete **KDE Plasma desktop environment** on your Android device using [Termux](https://termux.dev/) and [Termux:X11](https://github.com/termux/termux-x11) — no root required.

> Run a real Linux desktop on your phone. No VM. No emulator. Just Termux.

---

## ✦ Features

- **Silent installation** — no output clutter, every step explained cleanly
- **Fully automatic** — no Y/n prompts during package installation
- **Shell detection** — auto-detects `zsh` or `bash` and writes to the right config file
- **Duplicate-safe** — never writes to your shell config twice
- **Terminal size check** — ensures proper display before starting (`88x35`)
- **Session stats** — shows time elapsed and data used after installation
- **MOTD on startup** — shows a reminder box every time Termux opens
- **One-command uninstall** — `TermuxKDE-Remove` cleans everything up
- **Error logging** — all errors saved to `~/termuxkde_error.log`

---

## ✦ Requirements

| Requirement | Details |
|---|---|
| 📱 **Android** | 7.0 or higher |
| 📦 **Termux** | Latest version from [F-Droid](https://f-droid.org/packages/com.termux/) |
| 🖥️ **Termux:X11** | Install from [GitHub Releases](https://github.com/termux/termux-x11/releases) |
| 📐 **Terminal size** | Minimum `88x35` (cols x lines) |
| 💾 **Storage** | ~5 GB free space |
| 🌐 **Internet** | Required during installation |

> ⚠️ **Do NOT install Termux from the Play Store** — it's outdated. Use F-Droid.

---

## ✦ Before You Start

Make sure your terminal is at least `88x35`. Check with:

```bash
echo "${COLUMNS}x${LINES}"
```

If it's too small, **pinch-zoom out** on the Termux keyboard to shrink the font size until the dimensions are right. The installer will tell you if the size is too small and refuse to run until it's fixed.

---

## ✦ Installation

```bash

# 1. Install ncurses-utils
apt install ncurses-utils

# 2. Run the script
curl -s https://raw.githubusercontent.com/zenoZ0x/TermuxKDE/refs/heads/master/install_termuxkde.sh | bash

```

The installer handles everything **silently and automatically** — no manual input needed after the initial confirmation.

---

## ✦ Usage

After installation, these commands are available globally:

```bash
startplasma       # Launch KDE Plasma GUI
stoplasma         # Stop the Desktop
TermuxKDE-Remove  # Uninstall everything
```

> If the commands aren't found yet, run: `source ~/.zshrc` or `source ~/.bashrc`

---

## ✦ What the Installer Does

```
[1]  Check terminal size (min 88x35)
[2]  Detect shell (zsh / bash)
[3]  Update & upgrade Termux packages  ── silent
[4]  Install x11-repo                  ── silent
[5]  Install termux-x11-nightly        ── silent
[6]  Install KDE Plasma                ── silent
[7]  Install KDE Applications          ── silent
[8]  Write launcher scripts to ~/bin/
[9]  Write MOTD reminder to shell config (duplicate-safe)
[10] Source shell config automatically
[11] Show session stats (time + data used)
```

---

## ✦ MOTD Preview

Every time Termux opens, you'll see:

```
  ╔══════════════════════════╗
  ║       TermuxKDE          ║
  ╠══════════════════════════╣
  ║  startplasma  → Start    ║
  ║  stoplasma    → Stop     ║
  ╠══════════════════════════╣
  ║  TermuxKDE-Remove → Uninstall ║
  ╚══════════════════════════╝
  ⚠ TermuxKDE-Remove will delete everything
```

---

## ✦ Uninstalling

```bash
TermuxKDE-Remove
```

This will ask for confirmation, then permanently remove:
- `startplasma`, `stoplasma`, `TermuxKDE-Remove` scripts
- All TermuxKDE entries from your shell config
- `plasma`, `kde-applications`, `termux-x11-nightly` packages
- `~/termuxkde_error.log`

> ⚠️ This action **cannot be undone**. Restart Termux after removal.

---

## ✦ Troubleshooting

| Problem | Fix |
|---|---|
| Terminal size error | Pinch-zoom out until size is `88x35` or larger |
| Black screen on launch | Make sure Termux:X11 app is open before running `startplasma` |
| Commands not found | Run `source ~/.zshrc` or `source ~/.bashrc` |
| Installation failed | Check `~/termuxkde_error.log` for details |
| Slow performance | Close background apps — KDE is resource-heavy |

---

## ✦ Project Structure

```
TermuxKDE/
├── install_termuxkde.sh   # Main installer script
├── README.md              # You are here
├── assets/banner.jpg        # README banner
└── LICENSE                # MIT License
```

---

## ✦ License

```
Copyright (c) 2026 0xNullGun. All Rights Reserved.
Released under the MIT License.
```

---

<div align="center">

Made with ❤️ by **0xNullGun**

*If this helped you, drop a ⭐ — it means a lot.*

</div>
