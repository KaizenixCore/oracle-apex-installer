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

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

<br>

---

<!-- ═══════════════════════════════════════════════════════════════════════════ -->
<!-- SUPPORT & FOOTER SECTION - MODERN & SLEEK DESIGN -->
<!-- ═══════════════════════════════════════════════════════════════════════════ -->

<div align="center">

<br>

<img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Smilies/Beating%20Heart.png" width="50"/>

## Support & Contribute

<p>
  <i>If this project saved you time, consider supporting its development!</i>
</p>

<br>

<!-- SUPPORT BUTTONS -->
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

<!-- CONTRIBUTION OPTIONS -->
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

<!-- AUTHOR SECTION -->
<img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Hand%20gestures/Love-You%20Gesture.png" width="45"/>

### Crafted with ❤️ by

# [Peyman Rasouli](https://github.com/KaizenixCore)

<sub>Full-Stack Developer & Open Source Enthusiast</sub>

<br>

<!-- SOCIAL & LINKS -->
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

<!-- FOOTER LINE -->
<img width="100%" src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=6,12,19,24,30&height=80&section=footer"/>

<sub>
  © 2024 <b>KaizenixCore</b> • Released under the <b>MIT License</b>
  <br><br>
  <img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Travel%20and%20places/Star.png" width="15"/>
  If you found this useful, please give it a star!
  <img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Travel%20and%20places/Star.png" width="15"/>
</sub>

</div>
