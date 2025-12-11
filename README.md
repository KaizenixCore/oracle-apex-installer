<div align="center">

<!-- ANIMATED HEADER -->
<img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Travel%20and%20places/Rocket.png" width="100" alt="Rocket"/>
<img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Travel%20and%20places/Glowing%20Star.png" width="60" alt="Star"/>
<img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Travel%20and%20places/Rocket.png" width="100" alt="Rocket"/>

<br><br>

# 🚀 Oracle APEX Ultimate Installer

<h3>
  <img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Gear.png" width="20"/>
  Automated • Secure • Docker-Based • Production Ready
  <img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Gear.png" width="20"/>
</h3>

<p><i>KaizenixCore Edition v1.0.0</i></p>

<!-- BADGES -->
<p>
  <img src="https://img.shields.io/badge/Version-1.0.0-blue?style=for-the-badge" alt="Version"/>
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License"/>
  <img src="https://img.shields.io/badge/Status-Stable-success?style=for-the-badge" alt="Status"/>
</p>

<p>
  <img src="https://img.shields.io/badge/Bash-Script-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Bash"/>
  <img src="https://img.shields.io/badge/Docker-Required-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker"/>
  <img src="https://img.shields.io/badge/Oracle-APEX-F80000?style=for-the-badge&logo=oracle&logoColor=white" alt="APEX"/>
  <img src="https://img.shields.io/badge/ORDS-25.1-orange?style=for-the-badge" alt="ORDS"/>
</p>

<br>

<!-- LANGUAGE NAVIGATION -->
<h3>🌍 Select Language</h3>

<table>
  <tr>
    <td align="center" style="padding: 20px;">
      <a href="#-english-documentation">
        <img src="https://flagcdn.com/w80/gb.png" width="60" style="border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.2);"/><br><br>
        <b>🇬🇧 English</b>
      </a>
    </td>
    <td align="center" style="padding: 20px;">
      <a href="docs/README.fa.md">
        <img src="https://flagcdn.com/w80/ir.png" width="60" style="border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.2);"/><br><br>
        <b>🇮🇷 فارسی</b>
      </a>
    </td>
    <td align="center" style="padding: 20px;">
      <a href="docs/README.de.md">
        <img src="https://flagcdn.com/w80/de.png" width="60" style="border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.2);"/><br><br>
        <b>🇩🇪 Deutsch</b>
      </a>
    </td>
  </tr>
</table>

</div>

<br>

---

<br>

<!-- ENGLISH DOCUMENTATION -->
<div id="-english-documentation"></div>

## 📖 About The Project

<img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Light%20Bulb.png" width="25" align="left"/>

**Oracle APEX Ultimate Installer** is a state-of-the-art Bash script designed to fully automate the deployment of **Oracle APEX**, **ORDS**, and **Oracle Database XE 21c**.

Using Docker, it creates a pristine, isolated environment and automatically handles complex configurations like **Error 571** patches and **Proxy Authentication** — saving you hours of manual setup!

<br>

### 🎯 What Is This Installer?

This is an **intelligent automation solution** that transforms a complex, multi-hour Oracle APEX installation process into a simple, automated workflow. Think of it as your personal DevOps engineer that:

- **Understands Your System**: Automatically detects your Linux distribution and adapts accordingly
- **Handles Dependencies**: Installs and configures Docker, Java, and all required tools
- **Deploys Everything**: Sets up Oracle Database XE 21c, APEX, and ORDS in perfect harmony
- **Fixes Common Issues**: Automatically patches known errors (571, 404, proxy authentication)
- **Provides Management Tools**: Creates helper scripts for easy day-to-day operations

<br>

### 🔧 What Does It Do?

<div align="center">

| Phase | What Happens | Why It Matters |
|:---:|:---|:---|
| **🔍 Pre-Flight** | System validation and compatibility checks | Ensures your system can run Oracle APEX |
| **📦 Dependencies** | Installs Docker, Java, curl, wget, unzip | Prepares your environment automatically |
| **🐳 Containerization** | Creates isolated Docker environment | Clean setup, no conflicts with existing software |
| **🗄️ Database Setup** | Deploys Oracle Database XE 21c | Production-grade database in minutes |
| **🌐 APEX Installation** | Installs Oracle Application Express | Low-code development platform ready |
| **⚡ ORDS Configuration** | Sets up Oracle REST Data Services | Web interface and REST APIs enabled |
| **🔧 Auto-Fixing** | Applies security patches and fixes | Prevents common installation errors |
| **📊 Verification** | Tests all components and generates report | Confirms everything works perfectly |

</div>

<br>

### 💡 Why Choose This Installer?

<table>
<tr>
<td width="50%" valign="top">

#### ❌ Traditional Manual Installation

- Takes **2-4 hours** of technical work
- Requires **deep Oracle knowledge**
- Complex **dependency management**
- Prone to **configuration errors**
- **No automated fixes** for common issues
- **Manual troubleshooting** required
- Risk of **system conflicts**
- No **management utilities** included

</td>
<td width="50%" valign="top">

#### ✅ Oracle APEX Ultimate Installer

- Completes in **10-15 minutes** automatically
- **No prior experience** needed
- **All dependencies** handled automatically
- **Pre-configured** best practices
- **Auto-fixes** common errors (571, 404)
- **Built-in diagnostics** and repair tools
- **Isolated Docker** environment
- **Complete management suite** included

</td>
</tr>
</table>

<br>

### 🚀 Installation Workflow

The installer follows a smart, battle-tested process in **7 phases**:

<br>

**PHASE 1: SYSTEM PREPARATION**
- Detect Linux distribution (Ubuntu/Debian/Fedora/openSUSE/etc)
- Check system resources (RAM, disk space, CPU)
- Verify internet connectivity
- Validate user permissions

**PHASE 2: DEPENDENCY INSTALLATION**
- Install Docker Engine
- Install Java (OpenJDK 17)
- Install system utilities (curl, wget, unzip)
- Configure Docker permissions

**PHASE 3: DOCKER ENVIRONMENT**
- Pull Oracle Database XE 21c image
- Create Docker network
- Set up persistent volumes
- Configure port mappings (1521, 8080)

**PHASE 4: DATABASE DEPLOYMENT**
- Start Oracle Database container
- Wait for database initialization
- Create database users and schemas
- Configure security and permissions

**PHASE 5: APEX INSTALLATION**
- Download Oracle APEX (latest version)
- Extract and prepare files
- Install APEX schemas in database
- Create INTERNAL workspace
- Set up ADMIN user with secure password

**PHASE 6: ORDS CONFIGURATION**
- Download Oracle REST Data Services
- Configure connection pools
- Enable REST APIs
- Apply Error 571 fix
- Configure proxy authentication
- Start ORDS on port 8080

**PHASE 7: POST-INSTALLATION**
- Create management scripts (start/stop/status/fix/logs)
- Run system health checks
- Generate installation report
- Display access credentials and URLs

<br>

### 🎁 What You Get

After installation completes, you'll have:

<div align="center">

| Component | Description | Access |
|:---:|:---|:---|
| **🗄️ Oracle Database XE 21c** | Enterprise-grade database | Port 1521 |
| **🌐 Oracle APEX** | Low-code development platform | Web interface |
| **⚡ Oracle ORDS** | REST Data Services | Port 8080 |
| **🛠️ Management Scripts** | Start, stop, status, fix, logs | Scripts folder |
| **📊 Admin Dashboard** | Full APEX administration | Web interface |
| **🔐 Secure Configuration** | Best practices applied | Password-protected |

</div>

<br>

## ✨ Key Features

<div align="center">
<table>
  <tr>
    <td align="center" width="25%">
      <img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Package.png" width="50"/><br><br>
      <b>🐳 Docker Isolated</b><br>
      <sub>Clean & Safe Environment</sub>
    </td>
    <td align="center" width="25%">
      <img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Wrench.png" width="50"/><br><br>
      <b>🔧 Auto Fixes</b><br>
      <sub>Patches Error 571 & 404</sub>
    </td>
    <td align="center" width="25%">
      <img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Locked%20with%20Key.png" width="50"/><br><br>
      <b>🔒 Secure</b><br>
      <sub>Strict Password Policies</sub>
    </td>
    <td align="center" width="25%">
      <img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Desktop%20Computer.png" width="50"/><br><br>
      <b>🐧 Multi-Distro</b><br>
      <sub>Works on Any Linux</sub>
    </td>
  </tr>
  <tr>
    <td align="center" width="25%">
      <img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Rocket.png" width="50"/><br><br>
      <b>⚡ Lightning Fast</b><br>
      <sub>10-15 Minutes Setup</sub>
    </td>
    <td align="center" width="25%">
      <img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Books.png" width="50"/><br><br>
      <b>📚 Multi-Language</b><br>
      <sub>English, Persian, German</sub>
    </td>
    <td align="center" width="25%">
      <img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Hammer%20and%20Wrench.png" width="50"/><br><br>
      <b>🛠️ Management Tools</b><br>
      <sub>Built-in Helper Scripts</sub>
    </td>
    <td align="center" width="25%">
      <img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Check%20Mark%20Button.png" width="50"/><br><br>
      <b>✅ Production Ready</b><br>
      <sub>Battle-Tested & Stable</sub>
    </td>
  </tr>
</table>
</div>

<br>

## 📋 Access Information

<div align="center">

Once the installation is complete, use these credentials:

| Service | URL / Details |
| :--- | :--- |
| 🔐 **Admin Panel** | `http://localhost:8080/ords/apex_admin` |
| 🏠 **Landing Page** | `http://localhost:8080/ords/_/landing` |
| 👤 **Login Page** | `http://localhost:8080/ords/f?p=4550` |
| 🏢 **Workspace** | `INTERNAL` |
| 👤 **Username** | `ADMIN` |
| 🔑 **Password** | *(Set during installation)* |

</div>

<br>

## 🛠️ Management Scripts

<div align="center">

Helper scripts are located in `~/oracle-apex-complete/scripts/`:

| Script | Command | Description |
| :---: | :--- | :--- |
| 🟢 **Start** | `bash scripts/start.sh` | Starts Database and ORDS services |
| 🔴 **Stop** | `bash scripts/stop.sh` | Stops all containers and services |
| 📊 **Status** | `bash scripts/status.sh` | Checks health of DB and ORDS |
| 🔧 **Fix** | `bash scripts/fix.sh` | Runs comprehensive repair tools |
| 📜 **Logs** | `bash scripts/logs.sh` | View real-time logs |

</div>

<br>

## 📸 Screenshots

<div align="center">

### 🖥️ Installation Process

| Step 1: Starting Installation | Step 2: Installing Components | Step 3: Installation Complete |
| :---: | :---: | :---: |
| ![Start](assets/screenshots/install-1.png) | ![Progress](assets/screenshots/install-2.png) | ![Complete](assets/screenshots/install-3.png) |

<br>

### 🌐 Web Interface

| Landing Page | APEX Dashboard |
| :---: | :---: |
| ![Landing](assets/screenshots/landing.png) | ![Dashboard](assets/screenshots/dashboard.png) |

</div>

<br>

## 📝 System Requirements

<div align="center">

| Requirement | Minimum | Recommended |
| :--- | :---: | :---: |
| **🖥️ Operating System** | Linux (Any Distro) | Ubuntu 22.04 / openSUSE |
| **🐳 Docker** | v20.10+ | v24.0+ |
| **☕ Java** | OpenJDK 11 | OpenJDK 17+ |
| **💾 RAM** | 4 GB | 8 GB+ |
| **💿 Disk Space** | 20 GB | 50 GB+ |
| **🌐 Network** | Internet Required | Stable Connection |

</div>

<br>

## ㅤ

___🚀 Quick Installation___
```
curl -fsSL https://raw.githubusercontent.com/KaizenixCore/oracle-apex-installer/main/oracle-apex-installer.sh -o install.sh && chmod +x install.sh && bash install.sh

```
***
<br>

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

<br>

---

<div align="center">

<br>

<img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Smilies/Beating%20Heart.png" width="50"/>

## Support & Contribute

<p>
  <i>If this project saved you time, consider supporting its development!</i>
</p>

<br>

<a href="https://daramet.com/KaizenixCore">
  <img src="https://img.shields.io/badge/💖_Sponsor_on_Daramet-FF6B6B?style=for-the-badge" alt="Sponsor"/>
</a>
&nbsp;&nbsp;
<a href="https://daramet.com/KaizenixCore">
  <img src="https://img.shields.io/badge/☕_Buy_Me_Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black" alt="Coffee"/>
</a>
&nbsp;&nbsp;
<a href="https://github.com/KaizenixCore/oracle-apex-installer/stargazers">
  <img src="https://img.shields.io/badge/⭐_Star_This_Repo-181717?style=for-the-badge&logo=github" alt="Star"/>
</a>

<br><br>

<table>
  <tr>
    <td align="center" width="33%">
      <img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Money%20Bag.png" width="40"/><br>
      <b>Financial Support</b><br>
      <sub><a href="https://daramet.com/KaizenixCore">Donate via Daramet</a></sub>
    </td>
    <td align="center" width="33%">
      <img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Megaphone.png" width="40"/><br>
      <b>Spread the Word</b><br>
      <sub>Share with your network</sub>
    </td>
    <td align="center" width="33%">
      <img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Laptop.png" width="40"/><br>
      <b>Contribute Code</b><br>
      <sub><a href="https://github.com/KaizenixCore/oracle-apex-installer/pulls">Submit a PR</a></sub>
    </td>
  </tr>
</table>

<br>

---

<br>

<img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Hand%20gestures/Love-You%20Gesture.png" width="45"/>

### Crafted with ❤️ by

# [Peyman Rasouli](https://github.com/KaizenixCore)

<sub>Full-Stack Developer & Open Source Enthusiast</sub>

<br>

<a href="https://github.com/KaizenixCore">
  <img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub"/>
</a>
&nbsp;
<a href="https://github.com/KaizenixCore/oracle-apex-installer/issues">
  <img src="https://img.shields.io/badge/Report_Bug-DC3545?style=for-the-badge&logo=github&logoColor=white" alt="Bug"/>
</a>
&nbsp;
<a href="https://github.com/KaizenixCore/oracle-apex-installer/discussions">
  <img src="https://img.shields.io/badge/Discussions-5865F2?style=for-the-badge&logo=github&logoColor=white" alt="Discussions"/>
</a>
&nbsp;
<a href="https://daramet.com/KaizenixCore">
  <img src="https://img.shields.io/badge/Donate-FF6B6B?style=for-the-badge&logo=heart&logoColor=white" alt="Donate"/>
</a>

<br><br>

<img width="100%" src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=6,12,19,24,30&height=80&section=footer"/>

<sub>
  © 2024 <b>KaizenixCore</b> • Released under the <b>MIT License</b>
  <br><br>
  <img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Travel%20and%20places/Star.png" width="15"/>
  If you found this useful, please give it a star!
  <img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Travel%20and%20places/Star.png" width="15"/>
</sub>

</div>
