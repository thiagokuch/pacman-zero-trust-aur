# 🛡️ pacman-zta

> Zero Trust AUR Package Manager for Arch Linux

![License](https://img.shields.io/badge/license-MIT-blue)
![Shell](https://img.shields.io/badge/shell-bash-green)
![Arch Linux](https://img.shields.io/badge/Arch-Linux-1793d1)
![Security](https://img.shields.io/badge/model-zero--trust-red)

A security-first wrapper around `pacman` for users who prefer **trust over convenience**.

---

# 🛡 Philosophy

> Trust should be earned, not assumed.

`pacman-zta` intentionally sacrifices convenience for safety.

Packages are continuously re-evaluated against previously approved states.

Suspicious changes do not automatically become trusted.

---

# ✨ Features

| Feature                     | Supported |
| --------------------------- | :-------: |
| Official repositories first |     ✅     |
| Reputation checks           |     ✅     |
| PKGBUILD analysis           |     ✅     |
| .install analysis           |     ✅     |
| Shellcheck integration      |     ✅     |
| Namcap integration          |     ✅     |
| Security score              |     ✅     |
| Soft failures               |     ✅     |
| Hard failures               |     ✅     |
| Historical tracking         |     ✅     |
| Commit hash tracking        |     ✅     |
| Maintainer change detection |     ✅     |
| Commit growth detection     |     ✅     |
| Manual review mode          |     ✅     |
| Offline builds              |     ✅     |
| Hardened systemd sandbox    |     ✅     |
| Snapper integration         |     ✅     |
| Package auditing            |     ✅     |
| Installed package re-audit  |     ✅     |
| Bash completion             |     ✅     |
| Zsh completion              |     ✅     |
| Zero Trust policy           |     ✅     |

---

# 🔒 Zero Trust Workflow

```text
clone
 ↓
reputation checks
 ↓
PKGBUILD analysis
 ↓
.install analysis
 ↓
shellcheck + namcap
 ↓
history checks
 ↓
security score
 ↓
PASS / REVIEW / BLOCK
 ↓
(optional confirmation)
 ↓
offline build
 ↓
snapper snapshot
 ↓
install
 ↓
update approved state
```

---

# 📊 Security Score

|  Score | Level     |
| -----: | --------- |
| 90-100 | EXCELLENT |
|  75-89 | GOOD      |
|  50-74 | WARNING   |
|   0-49 | CRITICAL  |

Soft failures reduce the score.

Hard failures always block installation.

---

# 🚫 Hard Failures

Always block installation.

Examples:

* SKIP checksums
* Dangerous command patterns
* Suspicious `.install` hooks
* Namcap failures
* Clone failures

---

# ⚠ Soft Failures

May require user confirmation.

Examples:

* Commit hash changes
* Maintainer changes
* Large commit growth
* Low popularity
* Low vote count
* Shellcheck findings

---

# 🔎 Audit Results

Three possible outcomes exist:

| Result | Meaning                    |
| ------ | -------------------------- |
| PASS   | Package passed all checks  |
| REVIEW | User confirmation required |
| BLOCK  | Installation denied        |

Example:

```text
Audit result: PASS
```

```text
Audit result: REVIEW
```

```text
Audit result: BLOCK
```

---

# 🗃 Historical State

Location:

```text
~/.local/share/pacman-zta/state
```

Two state databases are maintained:

```text
package.last.state
package.approved.state
```

### last.state

Updated after every audit.

### approved.state

Updated only after:

* PASS
* REVIEW + explicit user approval

Historical comparisons are always performed against the approved state.

Tracked values:

* audit timestamp
* previous score
* commit hash
* commit count
* maintainer
* snapshot id

---

# 📸 Snapper Integration

After:

* successful audit;
* optional manual review;
* successful build;

and immediately before installation, a snapshot is created:

```text
PRE-AUR: dropbox
```

The snapshot ID is stored in the approved state.

Example:

```text
Snapshot ID: 328
```

This provides rollback capability after installation.

---

# 🔎 Audit

```bash
pacman-zta audit dropbox
```

Stages:

```text
REPUTATION
PKGBUILD
INSTALL HOOKS
SHELLCHECK / NAMCAP
HISTORY
RESULT
```

Possible results:

```text
Audit result: PASS
```

```text
Audit result: REVIEW
```

```text
Audit result: BLOCK
```

---

# ⌨ Shell Completion

Supported shells:

* Bash
* Zsh

Command completion:

```bash
pacman-zta <TAB>
```

Package completion:

```bash
pacman-zta install <TAB>
pacman-zta audit <TAB>
```
# 📦 Commands

| Command           | Description                 |
| ----------------- | --------------------------- |
| `install`         | Install packages            |
| `remove`          | Remove packages             |
| `update`          | Update system               |
| `status`          | Show package information    |
| `list`            | List managed packages       |
| `clean`           | Clean cache                 |
| `audit`           | Audit package               |
| `audit-installed` | Re-audit installed packages |
| `doctor`          | Verify dependencies         |
| `version`         | Show version                |

---

# 🔎 Audit Installed Packages

```bash
pacman-zta audit-installed
```

Example:

```text
dropbox                    PASS
sublime-text-4             PASS
heroic-games-launcher-bin  REVIEW
spotify                    BLOCK

Summary

PASS   : 14
REVIEW : 1
BLOCK  : 1
```

Installed packages are continuously compared against their last approved states.

---

# 🩺 Doctor

Verify dependencies and configuration:

```bash
pacman-zta doctor
```

Checks:

* jq
* curl
* git
* shellcheck
* namcap
* systemd-run
* snapper

---

# ⚙ Configuration

File:

```text
~/.config/pacman-zta.conf
```

Defaults:

```bash
MIN_AGE_DAYS=90
MIN_VOTES=10
MIN_POPULARITY=1.0
```

Example:

```bash
MIN_AGE_DAYS=180
MIN_VOTES=25
MIN_POPULARITY=5
```

---

# 🚀 Installation

Clone the repository:

```bash
git clone https://github.com/yourname/pacman-zta
cd pacman-zta
```

Run:

```bash
chmod +x install-pacman-zta.sh
./install-pacman-zta.sh
```

Binary location:

```text
~/.local/bin/pacman-zta
```

Shell completions are automatically installed for:

* Bash
* Zsh

---

# 🔄 Update Workflow

```bash
pacman-zta update
```

Workflow:

```text
audit
 ↓
PASS / REVIEW
 ↓
build
 ↓
snapper snapshot
 ↓
install
 ↓
update approved state
```

---

# 🔙 Rollback

When Snapper is enabled, the snapshot ID is stored in the package state.

Example:

```text
Snapshot ID: 328
```

Rollback:

```bash
sudo snapper rollback 328
```

This allows reverting the system to the state immediately before package installation.

---

# 📈 History Tracking

The following changes are tracked:

* commit hash changes
* maintainer changes
* unusual commit growth
* previous score
* audit timestamp

Packages are compared against the last approved state, not against the last audit.

Rejected versions never become trusted automatically.

---

# 🔐 Zero Trust Policy

There are intentionally no:

* ❌ force flags
* ❌ ignore flags
* ❌ unsafe modes
* ❌ bypass options

If something looks suspicious, installation stops.

Trust must be explicitly granted.

# 📁 Project Structure

```text
pacman-zta/

├── 01-foundation.sh
├── 02-aur-reputation.sh
├── 03-git-hash.sh
├── 04-pkgbuild-analyzer.sh
├── 05-install-hook.sh
├── 06-shellcheck-namcap.sh
├── 07-snapper.sh
├── 08-sandbox.sh
├── 09-build.sh
├── 10-install.sh
├── 11-update.sh
├── 12-status-cache.sh
├── 13-audit.sh
├── 14-audit-installed.sh
├── 15-history.sh
├── 16-score.sh
├── 17-history-checks.sh
├── 18-cli-main.sh
├── completion.bash
├── completion.zsh
├── install-pacman-zta.sh
├── uninstall-pacman-zta.sh
├── LICENSE
└── README.md
```

---

# 🏗 Build Process

The final binary is generated by concatenating all numbered modules:

```bash
cat [0-9][0-9]-*.sh > ~/.local/bin/pacman-zta
```

The CLI entry point is intentionally placed last:

```text
18-cli-main.sh
```

ensuring that all functions are loaded before:

```bash
main "$@"
```

is executed.

---

# 🔒 Security Philosophy

`pacman-zta` follows a Zero Trust approach.

Trust is not inherited.

Trust is not permanent.

Trust is continuously verified.

A package that was trusted yesterday may become suspicious today.

Previously rejected changes remain suspicious until explicitly approved.

---

# ❤️ Why?

The AUR is one of Arch Linux's greatest strengths.

It is also one of its largest attack surfaces.

Most AUR helpers optimize for convenience.

`pacman-zta` optimizes for trust.

It assumes:

* repositories may be compromised;
* maintainers may change;
* packages may become malicious;
* trust should expire;
* changes should be reviewed.

---

# 🚀 Example

```bash
pacman-zta install dropbox
```

Output:

```text
======================================
AUDITING dropbox
======================================

REPUTATION
PKGBUILD
INSTALL HOOKS
SHELLCHECK / NAMCAP
HISTORY
RESULT

Security score:           90/100
Failures detected:        1
Risk level:               EXCELLENT

Failures:

 - Commit hash changed since last audit

Audit result: REVIEW

Continue installation? [y/N]
```

After approval:

```text
Building package...

Creating pre-install snapshot...

Snapshot created: 328

Installing package...

dropbox installed successfully.
```

---

# 📜 License

MIT

---

# 🛡️ Security over convenience.

# 🤝 Trust over speed.

# 🔐 Zero Trust by default.
