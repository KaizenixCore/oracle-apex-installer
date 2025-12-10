<div align="center">

# 🚀 KaizenixCore - Oracle APEX Ultimate Installer

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Docker](https://img.shields.io/badge/Docker-Required-blue.svg)](https://www.docker.com/)
[![Oracle APEX](https://img.shields.io/badge/Oracle%20APEX-Latest-red.svg)](https://apex.oracle.com/)

**Fully automated installation of Oracle APEX + ORDS + Oracle XE 21c using Docker**

[🇬🇧 English](#-quick-start) • [🇮🇷 فارسی](README.fa.md) • [🇩🇪 Deutsch](README.de.md)

<img src="docs/screenshots/banner.png" alt="KaizenixCore Banner" width="600">

</div>

---

## ✨ Features

| Feature | Status |
|---------|--------|
| 🐳 Docker-based isolated environment | ✅ |
| 🔧 Error 571 & Proxy Authentication Fixed | ✅ |
| 🔐 ORDS Password Handling Fixed | ✅ |
| 🐧 Multi-Distribution Linux Support | ✅ |
| 📜 One-Click Management Scripts | ✅ |
| 📊 Comprehensive Logging | ✅ |
| 🔒 Password Validation | ✅ |

### Supported Linux Distributions

- ✅ Ubuntu / Debian
- ✅ Fedora / RHEL / CentOS
- ✅ openSUSE / SUSE
- ✅ Arch Linux (manual Docker install)

---

## 📋 Requirements

| Requirement | Minimum |
|-------------|---------|
| **RAM** | 4 GB |
| **Disk Space** | 15 GB free |
| **OS** | Linux 64-bit |
| **Internet** | Required for download |

> ⚠️ **Note:** Docker and Java 17 will be installed automatically if not present.

---

## 🚀 Quick Start

### One-Line Installation

```bash
curl -fsSL https://raw.githubusercontent.com/peymanrasouli/oracle-apex-installer/main/oracle-apex-installer.sh -o install.sh && chmod +x install.sh && bash install.sh
