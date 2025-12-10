<div align="center">

![KaizenixCore Banner](https://img.shields.io/badge/KaizenixCore-Oracle%20APEX%20Installer-orange?style=for-the-badge&logo=oracle)

# 🚀 KaizenixCore - Oracle APEX Ultimate Installer

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Shell-Bash%205.0+-green.svg)](https://www.gnu.org/software/bash/)
[![Docker](https://img.shields.io/badge/Docker-20.10+-blue.svg)](https://www.docker.com/)
[![Oracle APEX](https://img.shields.io/badge/Oracle%20APEX-24.1-red.svg)](https://apex.oracle.com/)
[![ORDS](https://img.shields.io/badge/ORDS-24.x-purple.svg)](https://www.oracle.com/database/technologies/appdev/rest.html)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/peymanrasouli/oracle-apex-installer/graphs/commit-activity)

### Fully Automated Installation of Oracle APEX + ORDS + Oracle XE 21c

**One script. Zero hassle. Complete Oracle APEX environment in minutes.**

[🇬🇧 English](#-quick-start) • [🇮🇷 فارسی](README.fa.md) • [🇩🇪 Deutsch](README.de.md)

---

<img src="docs/screenshots/banner.png" alt="KaizenixCore Banner" width="700">

</div>

---

## 📖 Table of Contents

- [Features](#-features)
- [Quick Start](#-quick-start)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Usage](#-usage)
- [Management Scripts](#-management-scripts)
- [Troubleshooting](#-troubleshooting)
- [Uninstallation](#-uninstallation)
- [Contributing](#-contributing)
- [License](#-license)
- [Author](#-author)

---

## ✨ Features

<table>
<tr>
<td>

### 🐳 Docker-Based
- Isolated environment
- No system pollution
- Easy cleanup

</td>
<td>

### 🔧 Auto-Fixed Issues
- Error 571 ✅
- Proxy Auth ✅
- Password handling ✅

</td>
<td>

### 🐧 Multi-Linux
- Ubuntu/Debian
- Fedora/RHEL
- openSUSE/SUSE

</td>
</tr>
</table>

| Feature | Description | Status |
|---------|-------------|--------|
| 🐳 **Docker Environment** | Isolated, containerized installation | ✅ |
| 🔧 **Error 571 Fix** | Proxy authentication automatically configured | ✅ |
| 🔐 **Password Handling** | ORDS install password issues resolved | ✅ |
| 👤 **APEX_PUBLIC_USER** | Proxy permissions properly granted | ✅ |
| 🐧 **Multi-Distribution** | Ubuntu, Debian, Fedora, RHEL, openSUSE | ✅ |
| 📜 **Management Scripts** | Start, Stop, Status, Fix, Logs | ✅ |
| 📊 **Logging** | Comprehensive installation logs | ✅ |
| 🔒 **Security** | Password validation & best practices | ✅ |
| ⚡ **Auto-Install** | Docker & Java installed automatically | ✅ |
| 🔄 **Smart Detection** | Skips already installed components | ✅ |

---

## 🚀 Quick Start

### One-Line Installation

```bash
curl -fsSL https://raw.githubusercontent.com/peymanrasouli/oracle-apex-installer/main/oracle-apex-installer.sh | bash
