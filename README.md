# kchangelog

`kchangelog` is a lightweight, dependency-free Bash script designed to monitor Ubuntu kernel changelogs and deliver system notifications when updates or new CVE patches are published. 

It is designed to run both interactively in the terminal and as a persistent background user service via `systemd`.

---

## Compatibility

**Yes, it works on any desktop environment.** 

Although originally tested on Cinnamon, `kchangelog` uses the universal `notify-send` utility (part of `libnotify`). This means desktop notifications are fully compatible with any modern X11 or Wayland desktop environment or window manager that implements a notification daemon, including:
*   **GNOME**
*   **KDE Plasma**
*   **Cinnamon**
*   **XFCE**
*   **MATE**
*   **i3WM / Sway / Dunst** (via DBus)

---

## Features

*   **Vibrant Colorization:** Highlighting of key changelog elements in the terminal (cyan package headers, dim gray signatures, bold red CVEs, and colored urgency levels). Bypasses escape codes when piping to logs or scripts.
*   **Keyword Grep Filtering:** Filter changelog entry blocks interactively by any pattern or keyword (`--grep PATTERN`).
*   **Debian-to-JSON Parser:** Directly translate raw changelogs into a structured, clean JSON array of objects (`--json`) perfect for integration or parsing.
*   **Changelog Fetching:** Downloads changelogs directly from Ubuntu's primary sources.
*   **Smart Resolution:** Automatically translates short kernel versions (e.g., `6.8` or active kernel) to exact package release versions via `apt-cache`.
*   **Granular Filters:** Filter by security vulnerabilities (`--cve`) or limit entries (`--last N`).
*   **Local Diffs:** Easily compare updates against the last read version (`--diff`).
*   **Kernel Version Listing:** Instantly retrieve, clean, and format all available kernel package versions in the local cache (`--list-available`).
*   **Subscription System:** Subscribe to multiple kernel releases (e.g., LTS kernels or active running kernels).
*   **Systemd Integration:** Seamless background scheduling via systemd user timers (running every 6 hours by default) with custom DBus environment mapping for reliable notifications.
*   **Universal Autocompletion:** Native autocompletion scripts for **Bash**, **Zsh**, and **Fish** supporting all options and dynamic kernel package suggestion.
*   **Professional Manpage:** Complete UNIX standard manual page (`man kchangelog`) explaining all commands, configuration files, and options.

---

## Prerequisites

*   **Linux (Ubuntu/Debian-based distribution)**
*   `bash`, `curl`, `awk`
*   `apt-cache` (for version resolution)
*   `libnotify-bin` (provides `notify-send`, optional but required for desktop notifications)
*   `systemd` (optional, for periodic background scanning)

---

## Installation & Setup

We provide a comprehensive `Makefile` to handle script validation, installation, shell completion configuration, manpage registration, and service deployment.

### 1. Complete Installation (Script + Universal Shell Completions + Manpage + Systemd Service)

Installs the executable globally, registers native autocompleters for **Bash**, **Zsh**, and **Fish**, installs the manual page, and automatically registers/enables the user timer service:
```bash
sudo make install
```
> **Note:** The `Makefile` automatically detects `sudo` usage and will configure the background systemd timer for the non-root invoking user (`$SUDO_USER`) rather than root.

### 2. Manual Installation

If you prefer installing components separately:

*   **Install the script only** (to `/usr/local/bin`):
    ```bash
    sudo make install-script
    ```

*   **Enable the systemd background check service** (for the current user, without `sudo`):
    ```bash
    make install-service
    ```

### 3. Verification

To verify that the script and all its primary flags are working correctly before/after deployment:
```bash
make check-flags
```

### 4. Uninstallation

Removes all installed binaries and deletes/cleans up the systemd user service:
```bash
sudo make uninstall
```

---

## Usage Examples

### Reading Changelogs

```bash
# Read changelog of the currently running kernel
kchangelog

# Read changelog of a specific major/minor kernel release
kchangelog 6.8

# Read a specific package version release
kchangelog 6.17.0-23

# Show only lines containing security CVEs
kchangelog --cve

# Show only the last 5 entries
kchangelog --last 5

# Interactive diff against your last read version
kchangelog --diff

# Open changelog directly inside your system $PAGER
kchangelog --open

# List all available kernel package versions in multiple columns
kchangelog --list-available

# Filter entries containing the keyword "intel" (case-insensitive)
kchangelog --grep "intel"

# Output structured JSON of the last 3 entries
kchangelog --json --last 3

# Force enable or disable colorized terminal formatting
kchangelog --color=always
kchangelog --color=never

# Read the professional manual page of the tool
man kchangelog
```

### Subscription Management

```bash
# Subscribe to the active running kernel
kchangelog --subscribe active

# Subscribe to a specific kernel series
kchangelog --subscribe 6.8

# List current active subscriptions
kchangelog --list-subs

# Unsubscribe from a series
kchangelog --unsubscribe 6.8
```

---

## JSON Output Schema

When running with `--json`, `kchangelog` parses raw changelogs into a standard JSON schema:

```json
[
  {
    "package": "linux-hwe-6.17",
    "version": "6.17.0-23.23~24.04.1",
    "urgency": "medium",
    "author": "Stefan Bader <stefan.bader@canonical.com>",
    "date": "Tue, 14 Apr 2026 16:36:31 +0200",
    "cves": [
      "CVE-2026-23231",
      "CVE-2026-23209",
      "CVE-2026-23112"
    ],
    "changes": [
      "noble/linux-hwe-6.17: 6.17.0-23.23~24.04.1 -proposed tracker (LP: #2147918)",
      "macvlan: observe an RCU grace period in macvlan_common_newlink() error path (LP: #2144380) // CVE-2026-23209"
    ]
  }
]
```

---

## License

This project is licensed under the GPLv3+ License. See the script headers for copyright details.
