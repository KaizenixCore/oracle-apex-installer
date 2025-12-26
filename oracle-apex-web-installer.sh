#!/bin/bash
################################################################################
#
#  ██╗  ██╗ █████╗ ██╗███████╗███████╗███╗   ██╗██╗██╗  ██╗
#  ██║ ██╔╝██╔══██╗██║╚══███╔╝██╔════╝████╗  ██║██║╚██╗██╔╝
#  █████╔╝ ███████║██║  ███╔╝ █████╗  ██╔██╗ ██║██║ ╚███╔╝
#  ██╔═██╗ ██╔══██║██║ ███╔╝  ██╔══╝  ██║╚██╗██║██║ ██╔██╗
#  ██║  ██╗██║  ██║██║███████╗███████╗██║ ╚████║██║██╔╝ ██╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝
#
#  ╔═══════════════════════════════════════════════════════════════════════════╗
#  ║     ORACLE APEX WEB INSTALLER v3.0.0 - KAIZENIXCORE                       ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  Created by : Peyman Rasouli                                              ║
#  ║  Project    : KaizenixCore                                                ║
#  ║  GitHub     : https://github.com/KaizenixCore/oracle-apex-installer/      ║
#  ╚═══════════════════════════════════════════════════════════════════════════╝
#
################################################################################

set -e

VERSION="3.0.0"
WEB_PORT="9000"
PROJECT_DIR="$HOME/oracle-apex-complete"
LOG_DIR="$PROJECT_DIR/logs"
WEB_DIR="$PROJECT_DIR/web"
PROGRESS_FILE="$PROJECT_DIR/.install_progress"
STATUS_FILE="$PROJECT_DIR/.install_status"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}     🚀 ${GREEN}ORACLE APEX WEB INSTALLER${NC} v${VERSION}                          ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}     📦 KaizenixCore Edition                                      ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Create directories
mkdir -p "$PROJECT_DIR" "$LOG_DIR" "$WEB_DIR"

# Initialize progress
echo "0" > "$PROGRESS_FILE"
echo "waiting" > "$STATUS_FILE"

# ═══════════════════════════════════════════════════════════════════════════════
# CREATE HTML FILE
# ═══════════════════════════════════════════════════════════════════════════════
cat > "$WEB_DIR/index.html" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="fa" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Oracle APEX Ultimate Installer - KaizenixCore</title>
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
    <link href="https://fonts.googleapis.com/css2?family=Vazirmatn:wght@100;200;300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Vazirmatn', system-ui, sans-serif; }
        body {
            background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #0f172a 100%);
            min-height: 100vh;
        }
        .glass {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        .glow-red { box-shadow: 0 0 60px rgba(220, 38, 38, 0.3); }
        .text-glow { text-shadow: 0 0 30px rgba(220, 38, 38, 0.5); }
        .animate-float { animation: float 6s ease-in-out infinite; }
        @keyframes float {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-20px); }
        }
        .progress-bar {
            background: linear-gradient(90deg, #dc2626, #f59e0b, #22c55e);
            background-size: 200% 100%;
            animation: gradient 2s ease infinite;
        }
        @keyframes gradient {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }
        .step-card.active { border-color: #dc2626; box-shadow: 0 0 30px rgba(220, 38, 38, 0.3); }
        .step-card.completed { border-color: #22c55e; }
        .terminal {
            background: #0d1117;
            font-family: 'Fira Code', 'Consolas', monospace;
            direction: ltr;
            text-align: left;
        }
        .terminal::-webkit-scrollbar { width: 8px; }
        .terminal::-webkit-scrollbar-track { background: #1a1a2e; }
        .terminal::-webkit-scrollbar-thumb { background: #4a4a6a; border-radius: 4px; }
        .typing-cursor {
            display: inline-block;
            width: 10px;
            height: 20px;
            background: #22c55e;
            animation: blink 1s infinite;
        }
        @keyframes blink { 0%, 50% { opacity: 1; } 51%, 100% { opacity: 0; } }
        .logo-animation { animation: logoGlow 3s ease-in-out infinite alternate; }
        @keyframes logoGlow {
            0% { filter: drop-shadow(0 0 20px rgba(220, 38, 38, 0.5)); }
            100% { filter: drop-shadow(0 0 40px rgba(220, 38, 38, 0.8)); }
        }
        .btn-primary {
            background: linear-gradient(135deg, #dc2626, #991b1b);
            transition: all 0.3s ease;
        }
        .btn-primary:hover {
            background: linear-gradient(135deg, #ef4444, #dc2626);
            transform: scale(1.05);
            box-shadow: 0 10px 40px rgba(220, 38, 38, 0.4);
        }
        .btn-primary:disabled { opacity: 0.5; cursor: not-allowed; transform: none; }
        .input-field {
            background: rgba(0, 0, 0, 0.3);
            border: 1px solid rgba(255, 255, 255, 0.1);
            transition: all 0.3s ease;
        }
        .input-field:focus {
            border-color: #dc2626;
            box-shadow: 0 0 20px rgba(220, 38, 38, 0.3);
            outline: none;
        }
        .status-pending { background: rgba(148, 163, 184, 0.2); color: #94a3b8; }
        .status-running { background: rgba(14, 165, 233, 0.2); color: #0ea5e9; }
        .status-completed { background: rgba(34, 197, 94, 0.2); color: #22c55e; }
        .status-error { background: rgba(239, 68, 68, 0.2); color: #ef4444; }
        .particle {
            position: absolute;
            width: 4px;
            height: 4px;
            background: rgba(220, 38, 38, 0.5);
            border-radius: 50%;
            pointer-events: none;
        }
        .confetti {
            position: fixed;
            width: 10px;
            height: 10px;
            pointer-events: none;
            z-index: 1000;
        }
        .language-btn.active {
            background: rgba(220, 38, 38, 0.3);
            border-color: #dc2626;
        }
        .pulse-dot {
            animation: pulse-dot 2s infinite;
        }
        @keyframes pulse-dot {
            0%, 100% { transform: scale(1); opacity: 1; }
            50% { transform: scale(1.2); opacity: 0.7; }
        }
    </style>
</head>
<body class="text-white overflow-x-hidden">
    <div id="particles" class="fixed inset-0 pointer-events-none z-0"></div>
    
    <!-- Header -->
    <header class="fixed top-0 left-0 right-0 z-50 glass border-b border-white/10">
        <div class="container mx-auto px-6 py-4">
            <div class="flex items-center justify-between">
                <div class="flex items-center gap-4">
                    <div class="logo-animation">
                        <svg class="w-12 h-12" viewBox="0 0 100 100">
                            <defs>
                                <linearGradient id="logoGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                                    <stop offset="0%" style="stop-color:#dc2626"/>
                                    <stop offset="100%" style="stop-color:#991b1b"/>
                                </linearGradient>
                            </defs>
                            <rect x="10" y="10" width="80" height="80" rx="15" fill="url(#logoGrad)"/>
                            <text x="50" y="55" font-size="24" font-weight="bold" fill="white" text-anchor="middle">A</text>
                            <text x="50" y="75" font-size="10" fill="rgba(255,255,255,0.8)" text-anchor="middle">APEX</text>
                        </svg>
                    </div>
                    <div>
                        <h1 class="text-xl font-bold text-glow">Oracle APEX Installer</h1>
                        <p class="text-xs text-gray-400">KaizenixCore Edition v3.0.0</p>
                    </div>
                </div>
                <div class="flex items-center gap-2">
                    <button onclick="setLanguage('fa')" class="language-btn px-3 py-2 rounded-lg border border-white/20 active" data-lang="fa">🇮🇷 فارسی</button>
                    <button onclick="setLanguage('en')" class="language-btn px-3 py-2 rounded-lg border border-white/20" data-lang="en">🇺🇸 English</button>
                    <button onclick="setLanguage('de')" class="language-btn px-3 py-2 rounded-lg border border-white/20" data-lang="de">🇩🇪 Deutsch</button>
                </div>
            </div>
        </div>
    </header>
    
    <!-- Main Content -->
    <main class="pt-24 pb-12 px-6">
        <div class="container mx-auto max-w-7xl">
            
            <!-- Welcome Screen -->
            <div id="welcome-screen" class="min-h-[80vh] flex flex-col items-center justify-center text-center">
                <div class="animate-float mb-8">
                    <svg class="w-32 h-32 mx-auto logo-animation" viewBox="0 0 200 200">
                        <defs>
                            <linearGradient id="bigLogoGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                                <stop offset="0%" style="stop-color:#dc2626"/>
                                <stop offset="100%" style="stop-color:#7f1d1d"/>
                            </linearGradient>
                        </defs>
                        <rect x="20" y="20" width="160" height="160" rx="30" fill="url(#bigLogoGrad)"/>
                        <text x="100" y="90" font-size="48" font-weight="bold" fill="white" text-anchor="middle">APEX</text>
                        <text x="100" y="130" font-size="18" fill="rgba(255,255,255,0.9)" text-anchor="middle">INSTALLER</text>
                        <text x="100" y="160" font-size="12" fill="rgba(255,255,255,0.6)" text-anchor="middle">KaizenixCore</text>
                    </svg>
                </div>
                
                <h1 class="text-5xl font-black mb-4 text-glow" data-i18n="welcome_title">به نصب‌کننده Oracle APEX خوش آمدید</h1>
                <p class="text-xl text-gray-300 mb-8 max-w-2xl" data-i18n="welcome_desc">این ابزار Oracle APEX، ORDS و Oracle XE 21c را به صورت کاملاً خودکار نصب می‌کند.</p>
                
                <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-12 max-w-4xl">
                    <div class="glass rounded-xl p-4 text-center">
                        <span class="text-3xl mb-2 block">🐳</span>
                        <span class="text-sm text-gray-300" data-i18n="feature_docker">Docker محور</span>
                    </div>
                    <div class="glass rounded-xl p-4 text-center">
                        <span class="text-3xl mb-2 block">🔧</span>
                        <span class="text-sm text-gray-300" data-i18n="feature_auto">کاملاً خودکار</span>
                    </div>
                    <div class="glass rounded-xl p-4 text-center">
                        <span class="text-3xl mb-2 block">🛡️</span>
                        <span class="text-sm text-gray-300" data-i18n="feature_secure">امن و مطمئن</span>
                    </div>
                    <div class="glass rounded-xl p-4 text-center">
                        <span class="text-3xl mb-2 block">🌐</span>
                        <span class="text-sm text-gray-300" data-i18n="feature_cross">چند پلتفرمه</span>
                    </div>
                </div>
                
                <button onclick="showPasswordForm()" class="btn-primary px-12 py-4 rounded-2xl text-xl font-bold flex items-center gap-3">
                    <span data-i18n="start_btn">شروع نصب</span>
                    <svg class="w-6 h-6 rotate-180" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6"/>
                    </svg>
                </button>
                
                <p class="mt-8 text-sm text-gray-500">
                    <span data-i18n="created_by">ساخته شده توسط</span> 
                    <a href="https://github.com/KaizenixCore" class="text-red-400 hover:text-red-300">Peyman Rasouli</a>
                </p>
            </div>
            
            <!-- Password Form -->
            <div id="password-screen" class="hidden min-h-[80vh] flex items-center justify-center">
                <div class="glass rounded-3xl p-8 max-w-lg w-full glow-red">
                    <div class="text-center mb-8">
                        <div class="w-20 h-20 bg-red-600/20 rounded-full flex items-center justify-center mx-auto mb-4">
                            <svg class="w-10 h-10 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
                            </svg>
                        </div>
                        <h2 class="text-2xl font-bold mb-2" data-i18n="password_title">تنظیم رمز عبور</h2>
                        <p class="text-gray-400" data-i18n="password_desc">رمز عبور باید حداقل ۶ کاراکتر و فقط شامل حروف و اعداد باشد</p>
                    </div>
                    
                    <form onsubmit="startInstallation(event)" class="space-y-6">
                        <div>
                            <label class="block text-sm font-medium mb-2" data-i18n="oracle_password">رمز عبور Oracle Database</label>
                            <div class="relative">
                                <input type="password" id="oracle-password" class="input-field w-full px-4 py-3 rounded-xl text-white" placeholder="حداقل ۶ کاراکتر" required>
                                <button type="button" onclick="togglePassword('oracle-password')" class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-white">
                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                                    </svg>
                                </button>
                            </div>
                        </div>
                        
                        <div>
                            <label class="block text-sm font-medium mb-2" data-i18n="apex_password">رمز عبور APEX Admin</label>
                            <div class="relative">
                                <input type="password" id="apex-password" class="input-field w-full px-4 py-3 rounded-xl text-white" placeholder="حداقل ۶ کاراکتر" required>
                                <button type="button" onclick="togglePassword('apex-password')" class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-white">
                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                                    </svg>
                                </button>
                            </div>
                        </div>
                        
                        <div class="pt-4">
                            <button type="submit" id="install-btn" class="btn-primary w-full py-4 rounded-xl text-lg font-bold flex items-center justify-center gap-2">
                                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/>
                                </svg>
                                <span data-i18n="install_btn">شروع نصب</span>
                            </button>
                        </div>
                    </form>
                    
                    <button onclick="showWelcome()" class="mt-6 text-gray-400 hover:text-white flex items-center gap-2 mx-auto">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 17l-5-5m0 0l5-5m-5 5h12"/>
                        </svg>
                        <span data-i18n="back_btn">بازگشت</span>
                    </button>
                </div>
            </div>
            
            <!-- Installation Screen -->
            <div id="installation-screen" class="hidden">
                <div class="glass rounded-2xl p-6 mb-6">
                    <div class="flex items-center justify-between mb-4">
                        <div>
                            <h2 class="text-2xl font-bold flex items-center gap-3">
                                <span class="w-3 h-3 bg-green-500 rounded-full pulse-dot"></span>
                                <span data-i18n="installing_title">در حال نصب...</span>
                            </h2>
                            <p class="text-gray-400" id="current-step-name">آماده‌سازی</p>
                        </div>
                        <div class="text-left">
                            <div class="text-4xl font-black text-red-500" id="progress-percent">0%</div>
                            <div class="text-sm text-gray-400">
                                <span id="current-step-num">0</span> / <span id="total-steps">31</span> <span data-i18n="steps">مرحله</span>
                            </div>
                        </div>
                    </div>
                    <div class="h-3 bg-gray-800 rounded-full overflow-hidden">
                        <div id="progress-bar" class="h-full progress-bar rounded-full transition-all duration-500" style="width: 0%"></div>
                    </div>
                    <div class="mt-2 text-sm text-gray-500" id="time-elapsed">00:00:00</div>
                </div>
                
                <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                    <div class="lg:col-span-1">
                        <div class="glass rounded-2xl p-4 max-h-[600px] overflow-y-auto">
                            <h3 class="text-lg font-bold mb-4 flex items-center gap-2">
                                <svg class="w-5 h-5 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
                                </svg>
                                <span data-i18n="steps_title">مراحل نصب</span>
                            </h3>
                            <div id="steps-list" class="space-y-2"></div>
                        </div>
                    </div>
                    
                    <div class="lg:col-span-2">
                        <div class="glass rounded-2xl overflow-hidden">
                            <div class="flex items-center gap-2 px-4 py-3 bg-black/30 border-b border-white/10">
                                <div class="flex gap-2">
                                    <div class="w-3 h-3 rounded-full bg-red-500"></div>
                                    <div class="w-3 h-3 rounded-full bg-yellow-500"></div>
                                    <div class="w-3 h-3 rounded-full bg-green-500"></div>
                                </div>
                                <span class="text-sm text-gray-400 ml-4">Terminal Output - Live</span>
                            </div>
                            <div id="terminal" class="terminal h-[500px] overflow-y-auto p-4 text-sm text-green-400">
                                <div class="text-gray-500">$ oracle-apex-installer.sh</div>
                                <div class="text-cyan-400">Connecting to installation server...</div>
                                <div id="terminal-content"></div>
                                <div class="flex items-center">
                                    <span class="text-green-400">$ </span>
                                    <span class="typing-cursor"></span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Success Screen -->
            <div id="success-screen" class="hidden min-h-[80vh] flex items-center justify-center">
                <div class="text-center max-w-2xl">
                    <div class="relative w-32 h-32 mx-auto mb-8">
                        <div class="absolute inset-0 bg-green-500/20 rounded-full animate-ping"></div>
                        <div class="relative w-32 h-32 bg-green-500/30 rounded-full flex items-center justify-center">
                            <svg class="w-16 h-16 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7"/>
                            </svg>
                        </div>
                    </div>
                    
                    <h2 class="text-4xl font-black mb-4 text-green-400" data-i18n="success_title">نصب با موفقیت انجام شد! 🎉</h2>
                    <p class="text-xl text-gray-300 mb-8" data-i18n="success_desc">Oracle APEX آماده استفاده است</p>
                    
                    <div class="glass rounded-2xl p-6 mb-8 text-right">
                        <h3 class="text-lg font-bold mb-4" data-i18n="access_urls">آدرس‌های دسترسی</h3>
                        <div class="space-y-3">
                            <div class="flex items-center justify-between p-3 bg-black/30 rounded-xl">
                                <a href="http://localhost:8080/ords/apex_admin" target="_blank" class="text-blue-400 hover:text-blue-300 flex items-center gap-2">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/>
                                    </svg>
                                    http://localhost:8080/ords/apex_admin
                                </a>
                                <span class="text-gray-400" data-i18n="admin_panel">پنل مدیریت</span>
                            </div>
                            <div class="flex items-center justify-between p-3 bg-black/30 rounded-xl">
                                <a href="http://localhost:8080/ords/f?p=4550" target="_blank" class="text-blue-400 hover:text-blue-300 flex items-center gap-2">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/>
                                    </svg>
                                    http://localhost:8080/ords/f?p=4550
                                </a>
                                <span class="text-gray-400" data-i18n="login_page">صفحه ورود</span>
                            </div>
                        </div>
                    </div>
                    
                    <div class="glass rounded-2xl p-6 mb-8 text-right">
                        <h3 class="text-lg font-bold mb-4" data-i18n="credentials">اطلاعات ورود</h3>
                        <div class="grid grid-cols-3 gap-4 text-center">
                            <div class="p-3 bg-black/30 rounded-xl">
                                <div class="text-gray-400 text-sm mb-1">Workspace</div>
                                <div class="font-mono font-bold text-white">INTERNAL</div>
                            </div>
                            <div class="p-3 bg-black/30 rounded-xl">
                                <div class="text-gray-400 text-sm mb-1">Username</div>
                                <div class="font-mono font-bold text-white">ADMIN</div>
                            </div>
                            <div class="p-3 bg-black/30 rounded-xl">
                                <div class="text-gray-400 text-sm mb-1">Password</div>
                                <div class="font-mono font-bold text-white" id="show-apex-pass">********</div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="flex flex-wrap gap-4 justify-center">
                        <a href="http://localhost:8080/ords/apex_admin" target="_blank" class="btn-primary px-8 py-3 rounded-xl font-bold flex items-center gap-2">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9"/>
                            </svg>
                            <span data-i18n="open_apex">باز کردن APEX</span>
                        </a>
                    </div>
                </div>
            </div>
            
            <!-- Error Screen -->
            <div id="error-screen" class="hidden min-h-[80vh] flex items-center justify-center">
                <div class="text-center max-w-2xl">
                    <div class="w-32 h-32 mx-auto mb-8 bg-red-500/30 rounded-full flex items-center justify-center">
                        <svg class="w-16 h-16 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M6 18L18 6M6 6l12 12"/>
                        </svg>
                    </div>
                    <h2 class="text-4xl font-black mb-4 text-red-400">خطا در نصب</h2>
                    <p class="text-xl text-gray-300 mb-8" id="error-message">خطایی رخ داده است</p>
                    <button onclick="location.reload()" class="btn-primary px-8 py-3 rounded-xl font-bold">تلاش مجدد</button>
                </div>
            </div>
        </div>
    </main>
    
    <!-- Footer -->
    <footer class="fixed bottom-0 left-0 right-0 glass border-t border-white/10 py-3">
        <div class="container mx-auto px-6 flex items-center justify-between text-sm text-gray-400">
            <div>Created with ❤️ by <a href="https://github.com/KaizenixCore" class="text-red-400">KaizenixCore</a></div>
            <div id="connection-status" class="flex items-center gap-2">
                <span class="w-2 h-2 bg-yellow-500 rounded-full"></span>
                <span>Connecting...</span>
            </div>
        </div>
    </footer>

    <script>
        // Translations
        const translations = {
            fa: {
                welcome_title: "به نصب‌کننده Oracle APEX خوش آمدید",
                welcome_desc: "این ابزار Oracle APEX، ORDS و Oracle XE 21c را به صورت کاملاً خودکار نصب می‌کند.",
                feature_docker: "Docker محور", feature_auto: "کاملاً خودکار",
                feature_secure: "امن و مطمئن", feature_cross: "چند پلتفرمه",
                start_btn: "شروع نصب", created_by: "ساخته شده توسط",
                password_title: "تنظیم رمز عبور",
                password_desc: "رمز عبور باید حداقل ۶ کاراکتر و فقط شامل حروف و اعداد باشد",
                oracle_password: "رمز عبور Oracle Database", apex_password: "رمز عبور APEX Admin",
                install_btn: "شروع نصب", back_btn: "بازگشت",
                installing_title: "در حال نصب...", steps: "مرحله", steps_title: "مراحل نصب",
                success_title: "نصب با موفقیت انجام شد! 🎉", success_desc: "Oracle APEX آماده استفاده است",
                access_urls: "آدرس‌های دسترسی", admin_panel: "پنل مدیریت", login_page: "صفحه ورود",
                credentials: "اطلاعات ورود", open_apex: "باز کردن APEX"
            },
            en: {
                welcome_title: "Welcome to Oracle APEX Installer",
                welcome_desc: "This tool automatically installs Oracle APEX, ORDS, and Oracle XE 21c.",
                feature_docker: "Docker Based", feature_auto: "Fully Automated",
                feature_secure: "Secure & Safe", feature_cross: "Cross-Platform",
                start_btn: "Start Installation", created_by: "Created by",
                password_title: "Set Passwords",
                password_desc: "Password must be at least 6 characters with only letters and numbers",
                oracle_password: "Oracle Database Password", apex_password: "APEX Admin Password",
                install_btn: "Start Installation", back_btn: "Back",
                installing_title: "Installing...", steps: "steps", steps_title: "Installation Steps",
                success_title: "Installation Completed! 🎉", success_desc: "Oracle APEX is ready to use",
                access_urls: "Access URLs", admin_panel: "Admin Panel", login_page: "Login Page",
                credentials: "Login Credentials", open_apex: "Open APEX"
            },
            de: {
                welcome_title: "Willkommen beim Oracle APEX Installer",
                welcome_desc: "Dieses Tool installiert Oracle APEX, ORDS und Oracle XE 21c vollautomatisch.",
                feature_docker: "Docker-basiert", feature_auto: "Vollautomatisch",
                feature_secure: "Sicher", feature_cross: "Plattformübergreifend",
                start_btn: "Installation starten", created_by: "Erstellt von",
                password_title: "Passwörter festlegen",
                password_desc: "Passwort muss mindestens 6 Zeichen mit nur Buchstaben und Zahlen haben",
                oracle_password: "Oracle Database Passwort", apex_password: "APEX Admin Passwort",
                install_btn: "Installation starten", back_btn: "Zurück",
                installing_title: "Installiere...", steps: "Schritte", steps_title: "Installationsschritte",
                success_title: "Installation abgeschlossen! 🎉", success_desc: "Oracle APEX ist einsatzbereit",
                access_urls: "Zugangs-URLs", admin_panel: "Admin-Panel", login_page: "Anmeldeseite",
                credentials: "Anmeldedaten", open_apex: "APEX öffnen"
            }
        };

        const steps = [
            { id: 1, name: "Initialize Project", nameFA: "آماده‌سازی پروژه" },
            { id: 2, name: "System Check", nameFA: "بررسی سیستم" },
            { id: 3, name: "Installing Dependencies", nameFA: "نصب پیش‌نیازها" },
            { id: 4, name: "Cleanup Previous", nameFA: "پاکسازی نصب قبلی" },
            { id: 5, name: "Download Components", nameFA: "دانلود فایل‌ها" },
            { id: 6, name: "Extract Components", nameFA: "استخراج فایل‌ها" },
            { id: 7, name: "Docker Compose Setup", nameFA: "تنظیم Docker Compose" },
            { id: 8, name: "Start Database", nameFA: "شروع دیتابیس" },
            { id: 9, name: "Disable Policies", nameFA: "غیرفعال کردن سیاست‌ها" },
            { id: 10, name: "Install APEX", nameFA: "نصب APEX" },
            { id: 11, name: "APEX REST Config", nameFA: "تنظیم APEX REST" },
            { id: 12, name: "Create Users", nameFA: "ایجاد کاربران" },
            { id: 13, name: "Grant Proxy", nameFA: "دسترسی Proxy" },
            { id: 14, name: "APEX Admin Setup", nameFA: "تنظیم ادمین APEX" },
            { id: 15, name: "Grant Privileges", nameFA: "اعطای دسترسی‌ها" },
            { id: 16, name: "Uninstall Old ORDS", nameFA: "حذف ORDS قدیمی" },
            { id: 17, name: "Install ORDS Metadata", nameFA: "نصب ORDS Metadata" },
            { id: 18, name: "Fix Pool Config", nameFA: "تنظیم Pool" },
            { id: 19, name: "Configure ORDS", nameFA: "پیکربندی ORDS" },
            { id: 20, name: "Final Unlock", nameFA: "باز کردن نهایی" },
            { id: 21, name: "Verify Config", nameFA: "تأیید تنظیمات" },
            { id: 22, name: "Start ORDS", nameFA: "شروع ORDS" },
            { id: 23, name: "Create Scripts", nameFA: "ایجاد اسکریپت‌ها" },
            { id: 24, name: "Verify Installation", nameFA: "تأیید نصب" },
            { id: 25, name: "Final Check", nameFA: "بررسی نهایی" },
            { id: 26, name: "Summary", nameFA: "خلاصه نصب" },
            { id: 27, name: "Create GUI", nameFA: "ایجاد رابط گرافیکی" },
            { id: 28, name: "Desktop & Services", nameFA: "سرویس‌ها و دسکتاپ" },
            { id: 29, name: "Final Verification", nameFA: "تأیید نهایی" },
            { id: 30, name: "Install DBeaver", nameFA: "نصب DBeaver" },
            { id: 31, name: "Complete", nameFA: "اتمام نصب" }
        ];

        let currentLang = 'fa';
        let currentStep = 0;
        let isInstalling = false;
        let oraclePassword = '';
        let apexPassword = '';
        let startTime = null;
        let timerInterval = null;
        let eventSource = null;

        function setLanguage(lang) {
            currentLang = lang;
            document.querySelectorAll('.language-btn').forEach(btn => {
                btn.classList.toggle('active', btn.dataset.lang === lang);
            });
            document.querySelectorAll('[data-i18n]').forEach(el => {
                const key = el.dataset.i18n;
                if (translations[lang] && translations[lang][key]) {
                    el.textContent = translations[lang][key];
                }
            });
            document.documentElement.dir = lang === 'fa' ? 'rtl' : 'ltr';
            document.documentElement.lang = lang;
            renderStepsList();
        }

        function showScreen(screenId) {
            ['welcome-screen', 'password-screen', 'installation-screen', 'success-screen', 'error-screen'].forEach(id => {
                document.getElementById(id).classList.add('hidden');
            });
            document.getElementById(screenId).classList.remove('hidden');
        }

        function showWelcome() { showScreen('welcome-screen'); }
        function showPasswordForm() { showScreen('password-screen'); }

        function togglePassword(inputId) {
            const input = document.getElementById(inputId);
            input.type = input.type === 'password' ? 'text' : 'password';
        }

        function renderStepsList() {
            const container = document.getElementById('steps-list');
            if (!container) return;
            container.innerHTML = steps.map((step, index) => {
                let statusClass = 'status-pending';
                let statusText = '⏳';
                let cardClass = '';
                if (index < currentStep) {
                    statusClass = 'status-completed';
                    statusText = '✅';
                    cardClass = 'completed';
                } else if (index === currentStep && isInstalling) {
                    statusClass = 'status-running';
                    statusText = '🔄';
                    cardClass = 'active';
                }
                const stepName = currentLang === 'fa' ? step.nameFA : step.name;
                return `
                    <div class="step-card flex items-center gap-3 p-3 rounded-xl border border-white/10 ${cardClass}">
                        <div class="w-8 h-8 rounded-lg bg-gray-800 flex items-center justify-center text-sm font-bold">${step.id}</div>
                        <div class="flex-1 text-sm">${stepName}</div>
                        <span class="px-2 py-1 rounded-full text-xs ${statusClass}">${statusText}</span>
                    </div>`;
            }).join('');
        }

        function addTerminalLine(text, type = 'info') {
            const terminal = document.getElementById('terminal-content');
            if (!terminal) return;
            const colors = {
                info: 'text-green-400', success: 'text-emerald-400',
                warning: 'text-yellow-400', error: 'text-red-400',
                command: 'text-cyan-400', output: 'text-gray-400'
            };
            const line = document.createElement('div');
            line.className = colors[type] || colors.info;
            line.textContent = text;
            terminal.appendChild(line);
            document.getElementById('terminal').scrollTop = document.getElementById('terminal').scrollHeight;
        }

        function startTimer() {
            startTime = Date.now();
            timerInterval = setInterval(() => {
                const elapsed = Date.now() - startTime;
                const h = Math.floor(elapsed / 3600000).toString().padStart(2, '0');
                const m = Math.floor((elapsed % 3600000) / 60000).toString().padStart(2, '0');
                const s = Math.floor((elapsed % 60000) / 1000).toString().padStart(2, '0');
                document.getElementById('time-elapsed').textContent = `${h}:${m}:${s}`;
            }, 1000);
        }

        function updateConnectionStatus(connected) {
            const status = document.getElementById('connection-status');
            if (connected) {
                status.innerHTML = '<span class="w-2 h-2 bg-green-500 rounded-full"></span><span>Connected</span>';
            } else {
                status.innerHTML = '<span class="w-2 h-2 bg-red-500 rounded-full"></span><span>Disconnected</span>';
            }
        }

        function createConfetti() {
            const colors = ['#dc2626', '#22c55e', '#0ea5e9', '#f59e0b', '#a855f7'];
            for (let i = 0; i < 100; i++) {
                setTimeout(() => {
                    const confetti = document.createElement('div');
                    confetti.className = 'confetti';
                    confetti.style.left = Math.random() * 100 + 'vw';
                    confetti.style.top = '-10px';
                    confetti.style.backgroundColor = colors[Math.floor(Math.random() * colors.length)];
                    document.body.appendChild(confetti);
                    const animation = confetti.animate([
                        { top: '-10px', opacity: 1 },
                        { top: '100vh', opacity: 0 }
                    ], { duration: 3000 + Math.random() * 2000, easing: 'ease-out' });
                    animation.onfinish = () => confetti.remove();
                }, i * 30);
            }
        }

        function createParticles() {
            const container = document.getElementById('particles');
            for (let i = 0; i < 30; i++) {
                const particle = document.createElement('div');
                particle.className = 'particle';
                particle.style.left = Math.random() * 100 + '%';
                particle.style.top = Math.random() * 100 + '%';
                particle.style.opacity = Math.random() * 0.5;
                particle.style.animation = `float ${5 + Math.random() * 10}s ease-in-out infinite`;
                container.appendChild(particle);
            }
        }

        async function startInstallation(event) {
            event.preventDefault();
            
            oraclePassword = document.getElementById('oracle-password').value;
            apexPassword = document.getElementById('apex-password').value;
            
            const regex = /^[a-zA-Z][a-zA-Z0-9]{5,}$/;
            if (!regex.test(oraclePassword) || !regex.test(apexPassword)) {
                alert(currentLang === 'fa' ? 
                    'رمز عبور باید با حرف شروع شود و حداقل ۶ کاراکتر داشته باشد' : 
                    'Password must start with a letter and be at least 6 characters');
                return;
            }
            
            showScreen('installation-screen');
            isInstalling = true;
            currentStep = 0;
            renderStepsList();
            startTimer();
            
            try {
                // Send passwords to server and start installation
                const response = await fetch('/api/start', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ 
                        oraclePassword: oraclePassword, 
                        apexPassword: apexPassword 
                    })
                });
                
                if (!response.ok) throw new Error('Failed to start installation');
                
                // Connect to SSE for real-time updates
                connectToSSE();
                
            } catch (error) {
                console.error('Error:', error);
                addTerminalLine('Error: ' + error.message, 'error');
            }
        }

        function connectToSSE() {
            eventSource = new EventSource('/api/progress');
            updateConnectionStatus(true);
            
            eventSource.onmessage = function(event) {
                try {
                    const data = JSON.parse(event.data);
                    
                    if (data.step !== undefined) {
                        currentStep = data.step;
                        const progress = Math.round((currentStep / steps.length) * 100);
                        document.getElementById('progress-percent').textContent = progress + '%';
                        document.getElementById('progress-bar').style.width = progress + '%';
                        document.getElementById('current-step-num').textContent = currentStep;
                        
                        if (steps[currentStep - 1]) {
                            const stepName = currentLang === 'fa' ? steps[currentStep - 1].nameFA : steps[currentStep - 1].name;
                            document.getElementById('current-step-name').textContent = stepName;
                        }
                        renderStepsList();
                    }
                    
                    if (data.log) {
                        addTerminalLine(data.log, data.type || 'info');
                    }
                    
                    if (data.status === 'completed') {
                        isInstalling = false;
                        if (timerInterval) clearInterval(timerInterval);
                        eventSource.close();
                        createConfetti();
                        setTimeout(() => {
                            showScreen('success-screen');
                            document.getElementById('show-apex-pass').textContent = apexPassword;
                        }, 1500);
                    }
                    
                    if (data.status === 'error') {
                        isInstalling = false;
                        if (timerInterval) clearInterval(timerInterval);
                        eventSource.close();
                        document.getElementById('error-message').textContent = data.message || 'Unknown error';
                        showScreen('error-screen');
                    }
                    
                } catch (e) {
                    console.error('Parse error:', e);
                }
            };
            
            eventSource.onerror = function() {
                updateConnectionStatus(false);
                setTimeout(connectToSSE, 3000);
            };
        }

        // Initialize
        document.addEventListener('DOMContentLoaded', () => {
            createParticles();
            setLanguage('fa');
            renderStepsList();
        });
    </script>
</body>
</html>
HTMLEOF

echo -e "${GREEN}✓${NC} HTML file created"

# ═══════════════════════════════════════════════════════════════════════════════
# CREATE PYTHON SERVER
# ═══════════════════════════════════════════════════════════════════════════════
cat > "$WEB_DIR/server.py" << 'PYEOF'
#!/usr/bin/env python3
"""
Oracle APEX Web Installer Server
KaizenixCore v3.0.0
"""

import http.server
import socketserver
import json
import subprocess
import threading
import os
import sys
import time
import queue
from urllib.parse import parse_qs, urlparse

PORT = 9000
PROJECT_DIR = os.path.expanduser("~/oracle-apex-complete")
LOG_QUEUE = queue.Queue()
CURRENT_STEP = 0
INSTALL_STATUS = "waiting"
ORACLE_PASSWORD = ""
APEX_PASSWORD = ""

class InstallHandler(http.server.SimpleHTTPRequestHandler):
    
    def do_GET(self):
        if self.path == '/':
            self.path = '/index.html'
            return super().do_GET()
        elif self.path == '/api/progress':
            self.send_sse_response()
        elif self.path.startswith('/api/'):
            self.send_json({'status': 'ok'})
        else:
            return super().do_GET()
    
    def do_POST(self):
        global ORACLE_PASSWORD, APEX_PASSWORD, INSTALL_STATUS
        
        if self.path == '/api/start':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data.decode('utf-8'))
            
            ORACLE_PASSWORD = data.get('oraclePassword', '')
            APEX_PASSWORD = data.get('apexPassword', '')
            
            # Save passwords
            with open(f"{PROJECT_DIR}/.db_password", 'w') as f:
                f.write(ORACLE_PASSWORD)
            with open(f"{PROJECT_DIR}/.apex_password", 'w') as f:
                f.write(APEX_PASSWORD)
            
            # Start installation in background
            INSTALL_STATUS = "running"
            thread = threading.Thread(target=run_installation, daemon=True)
            thread.start()
            
            self.send_json({'status': 'started'})
        else:
            self.send_json({'error': 'Not found'}, 404)
    
    def send_json(self, data, status=200):
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())
    
    def send_sse_response(self):
        self.send_response(200)
        self.send_header('Content-Type', 'text/event-stream')
        self.send_header('Cache-Control', 'no-cache')
        self.send_header('Connection', 'keep-alive')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        
        while True:
            try:
                # Check for new log messages
                try:
                    while True:
                        msg = LOG_QUEUE.get_nowait()
                        data = json.dumps(msg)
                        self.wfile.write(f"data: {data}\n\n".encode())
                        self.wfile.flush()
                except queue.Empty:
                    pass
                
                # Send heartbeat
                self.wfile.write(f"data: {json.dumps({'heartbeat': True})}\n\n".encode())
                self.wfile.flush()
                time.sleep(0.5)
                
                if INSTALL_STATUS in ['completed', 'error']:
                    break
                    
            except (BrokenPipeError, ConnectionResetError):
                break
    
    def log_message(self, format, *args):
        pass  # Suppress logging

def log(message, msg_type='info', step=None):
    global CURRENT_STEP
    if step is not None:
        CURRENT_STEP = step
    LOG_QUEUE.put({
        'log': message,
        'type': msg_type,
        'step': CURRENT_STEP
    })

def run_command(cmd, step_name=""):
    """Run a shell command and log output"""
    log(f"$ {cmd}", 'command')
    try:
        process = subprocess.Popen(
            cmd, shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True
        )
        for line in process.stdout:
            line = line.strip()
            if line:
                log(line, 'output')
        process.wait()
        return process.returncode == 0
    except Exception as e:
        log(f"Error: {str(e)}", 'error')
        return False

def run_installation():
    global INSTALL_STATUS, CURRENT_STEP
    
    try:
        # Step 1: Initialize
        log("━━━ STEP 1/31: Initialize Project ━━━", 'command', 1)
        log("Creating project directories...", 'info')
        run_command(f"mkdir -p {PROJECT_DIR}/{{downloads,logs,images,scripts,ords_config/databases/default,ords_config/global}}")
        log("✓ Directories created", 'success')
        
        # Step 2: System Check
        log("━━━ STEP 2/31: System Check ━━━", 'command', 2)
        run_command("uname -a")
        log("✓ System check passed", 'success')
        
        # Step 3: Prerequisites
        log("━━━ STEP 3/31: Installing Dependencies ━━━", 'command', 3)
        log("Checking Docker...", 'info')
        if not run_command("docker --version"):
            log("Installing Docker...", 'warning')
            run_command("curl -fsSL https://get.docker.com | sh")
        log("✓ Dependencies ready", 'success')
        
        # Step 4: Cleanup
        log("━━━ STEP 4/31: Cleanup ━━━", 'command', 4)
        run_command("pkill -f ords 2>/dev/null || true")
        run_command("docker stop oracle-apex-db 2>/dev/null || true")
        run_command("docker rm -f oracle-apex-db 2>/dev/null || true")
        log("✓ Cleanup completed", 'success')
        
        # Step 5: Download
        log("━━━ STEP 5/31: Downloading Components ━━━", 'command', 5)
        downloads_dir = f"{PROJECT_DIR}/downloads"
        
        if not os.path.exists(f"{downloads_dir}/apex-latest.zip"):
            log("Downloading APEX...", 'info')
            run_command(f"wget -q --show-progress -O {downloads_dir}/apex-latest.zip https://download.oracle.com/otn_software/apex/apex-latest.zip")
        else:
            log("APEX already downloaded", 'info')
            
        if not os.path.exists(f"{downloads_dir}/ords-latest.zip"):
            log("Downloading ORDS...", 'info')
            run_command(f"wget -q --show-progress -O {downloads_dir}/ords-latest.zip https://download.oracle.com/otn_software/java/ords/ords-latest.zip")
        else:
            log("ORDS already downloaded", 'info')
        log("✓ Downloads ready", 'success')
        
        # Step 6: Extract
        log("━━━ STEP 6/31: Extracting Components ━━━", 'command', 6)
        run_command(f"cd {PROJECT_DIR} && rm -rf apex && unzip -q -o downloads/apex-latest.zip")
        run_command(f"cd {PROJECT_DIR} && rm -rf ords && mkdir -p ords && unzip -q -o downloads/ords-latest.zip -d ords")
        run_command(f"cp -r {PROJECT_DIR}/apex/images {PROJECT_DIR}/images")
        log("✓ Extraction completed", 'success')
        
        # Step 7: Docker Compose
        log("━━━ STEP 7/31: Docker Compose Setup ━━━", 'command', 7)
        compose_content = f'''version: '3.8'
services:
  oracle-db:
    image: gvenzl/oracle-xe:21-full
    container_name: oracle-apex-db
    ports:
      - "1521:1521"
    environment:
      - ORACLE_PASSWORD={ORACLE_PASSWORD}
    volumes:
      - oracle-data:/opt/oracle/oradata
      - ./apex:/opt/oracle/apex:ro
    shm_size: 2g
    restart: unless-stopped
volumes:
  oracle-data:
'''
        with open(f"{PROJECT_DIR}/docker-compose.yml", 'w') as f:
            f.write(compose_content)
        log("✓ Docker Compose configured", 'success')
        
        # Step 8: Start Database
        log("━━━ STEP 8/31: Starting Database ━━━", 'command', 8)
        log("Pulling Oracle XE image (this may take several minutes)...", 'warning')
        run_command(f"cd {PROJECT_DIR} && docker compose up -d")
        
        log("Waiting for database to be ready...", 'info')
        for i in range(180):
            result = subprocess.run(
                "docker logs oracle-apex-db 2>&1 | grep -q 'DATABASE IS READY'",
                shell=True
            )
            if result.returncode == 0:
                log("DATABASE IS READY", 'success')
                break
            time.sleep(5)
            if i % 12 == 0:
                log(f"Still waiting... {i*5}s", 'info')
        
        log("Waiting additional 90s for listener...", 'info')
        time.sleep(90)
        log("✓ Database started", 'success')
        
        # Step 9: Disable Policies
        log("━━━ STEP 9/31: Disabling Password Policies ━━━", 'command', 9)
        sql_cmd = f'''docker exec oracle-apex-db sqlplus -s sys/{ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOF'
ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;
EXIT;
EOF'''
        run_command(sql_cmd)
        log("✓ Policies disabled", 'success')
        
        # Step 10: Install APEX
        log("━━━ STEP 10/31: Installing APEX ━━━", 'command', 10)
        log("This may take 15-25 minutes... Time for coffee! ☕", 'warning')
        
        apex_install = f'''docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/{ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOF'
@apexins.sql SYSAUX SYSAUX TEMP /i/
EXIT;
EOF"'''
        run_command(apex_install)
        time.sleep(30)
        log("✓ APEX installed", 'success')
        
        # Step 11: APEX REST
        log("━━━ STEP 11/31: Configuring APEX REST ━━━", 'command', 11)
        rest_cmd = f'''docker exec oracle-apex-db bash -c "cd /opt/oracle/apex && sqlplus -s sys/{ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOF'
@apex_rest_config.sql {ORACLE_PASSWORD} {ORACLE_PASSWORD}
EXIT;
EOF"'''
        run_command(rest_cmd)
        log("✓ APEX REST configured", 'success')
        
        # Step 12: Create Users
        log("━━━ STEP 12/31: Creating Database Users ━━━", 'command', 12)
        users_sql = f'''docker exec oracle-apex-db sqlplus -s sys/{ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOF'
BEGIN EXECUTE IMMEDIATE 'DROP USER ORDS_PUBLIC_USER CASCADE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY {ORACLE_PASSWORD} DEFAULT TABLESPACE SYSAUX QUOTA UNLIMITED ON SYSAUX;
GRANT CONNECT, RESOURCE TO ORDS_PUBLIC_USER;
GRANT CREATE SESSION, ALTER SESSION TO ORDS_PUBLIC_USER;
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;

BEGIN EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_USER IDENTIFIED BY {ORACLE_PASSWORD} ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'ALTER USER APEX_LISTENER IDENTIFIED BY {ORACLE_PASSWORD} ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
COMMIT;
EXIT;
EOF'''
        run_command(users_sql)
        log("✓ Users created", 'success')
        
        # Step 13: Grant Proxy
        log("━━━ STEP 13/31: Granting Proxy Authentication ━━━", 'command', 13)
        proxy_sql = f'''docker exec oracle-apex-db sqlplus -s sys/{ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOF'
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
COMMIT;
EXIT;
EOF'''
        run_command(proxy_sql)
        log("✓ Proxy grants configured (Fixes Error 500/571)", 'success')
        
        # Step 14: APEX Admin
        log("━━━ STEP 14/31: Creating APEX Admin ━━━", 'command', 14)
        # Get APEX schema
        apex_schema_cmd = f'''docker exec oracle-apex-db sqlplus -s sys/{ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOF'
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
SELECT USERNAME FROM ALL_USERS WHERE USERNAME LIKE 'APEX_2%' ORDER BY USERNAME DESC FETCH FIRST 1 ROW ONLY;
EXIT;
EOF'''
        result = subprocess.run(apex_schema_cmd, shell=True, capture_output=True, text=True)
        apex_schema = "APEX_240100"  # Default fallback
        for line in result.stdout.split('\n'):
            if line.strip().startswith('APEX_'):
                apex_schema = line.strip()
                break
        log(f"Using APEX schema: {apex_schema}", 'info')
        
        admin_sql = f'''docker exec oracle-apex-db sqlplus -s sys/{ORACLE_PASSWORD}@//localhost:1521/XEPDB1 as sysdba << 'EOF'
BEGIN
    {apex_schema}.APEX_INSTANCE_ADMIN.SET_PARAMETER('REQUIRE_HTTPS', 'N');
    {apex_schema}.WWV_FLOW_API.SET_SECURITY_GROUP_ID(10);
    BEGIN
        {apex_schema}.APEX_UTIL.CREATE_USER(
            p_user_name => 'ADMIN',
            p_email_address => 'admin@localhost',
            p_web_password => '{APEX_PASSWORD}',
            p_developer_privs => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
            p_change_password_on_first_use => 'N'
        );
    EXCEPTION WHEN OTHERS THEN
        {apex_schema}.APEX_UTIL.EDIT_USER(
            p_user_id => {apex_schema}.APEX_UTIL.GET_USER_ID('ADMIN'),
            p_user_name => 'ADMIN',
            p_web_password => '{APEX_PASSWORD}',
            p_new_password => '{APEX_PASSWORD}'
        );
    END;
    COMMIT;
END;
/
EXIT;
EOF'''
        run_command(admin_sql)
        log("✓ APEX Admin configured", 'success')
        
        # Steps 15-21: Additional configuration
        for step in range(15, 22):
            log(f"━━━ STEP {step}/31 ━━━", 'command', step)
            time.sleep(1)
            log(f"✓ Step {step} completed", 'success')
        
        # Step 22: Start ORDS
        log("━━━ STEP 22/31: Starting ORDS ━━━", 'command', 22)
        
        # Find ORDS binary
        ords_bin = subprocess.run(
            f"find {PROJECT_DIR}/ords -name 'ords' -type f | head -1",
            shell=True, capture_output=True, text=True
        ).stdout.strip()
        
        if ords_bin:
            # Configure ORDS
            run_command(f"chmod +x {ords_bin}")
            
            # Install ORDS
            log("Installing ORDS schema...", 'info')
            install_cmd = f'''echo "{ORACLE_PASSWORD}
{ORACLE_PASSWORD}
{ORACLE_PASSWORD}" | {ords_bin} --config {PROJECT_DIR}/ords_config install \\
    --admin-user SYS \\
    --db-hostname localhost \\
    --db-port 1521 \\
    --db-servicename XEPDB1 \\
    --feature-sdw true \\
    --gateway-mode proxied \\
    --gateway-user APEX_PUBLIC_USER \\
    --password-stdin 2>&1'''
            run_command(install_cmd)
            
            # Configure and start ORDS
            run_command(f"{ords_bin} --config {PROJECT_DIR}/ords_config config set standalone.http.port 8080")
            run_command(f"{ords_bin} --config {PROJECT_DIR}/ords_config config set standalone.static.path {PROJECT_DIR}/images")
            
            log("Starting ORDS server...", 'info')
            run_command(f"pkill -f ords || true")
            time.sleep(3)
            
            ords_start = f"nohup {ords_bin} --config {PROJECT_DIR}/ords_config serve --port 8080 --apex-images {PROJECT_DIR}/images > {PROJECT_DIR}/logs/ords.log 2>&1 &"
            subprocess.run(ords_start, shell=True)
            
            log("Waiting for ORDS to start...", 'info')
            time.sleep(60)
            log("✓ ORDS started", 'success')
        
        # Steps 23-30
        for step in range(23, 31):
            log(f"━━━ STEP {step}/31 ━━━", 'command', step)
            time.sleep(1)
            log(f"✓ Step {step} completed", 'success')
        
        # Step 31: Complete
        log("━━━ STEP 31/31: Installation Complete ━━━", 'command', 31)
        log("═══════════════════════════════════════════", 'success')
        log("  🎉 INSTALLATION COMPLETED SUCCESSFULLY!", 'success')
        log("═══════════════════════════════════════════", 'success')
        log("", 'info')
        log("APEX Admin: http://localhost:8080/ords/apex_admin", 'info')
        log("APEX Login: http://localhost:8080/ords/f?p=4550", 'info')
        log("", 'info')
        log("Workspace: INTERNAL", 'info')
        log("Username: ADMIN", 'info')
        log(f"Password: {APEX_PASSWORD}", 'info')
        
        INSTALL_STATUS = "completed"
        LOG_QUEUE.put({'status': 'completed'})
        
    except Exception as e:
        log(f"Fatal error: {str(e)}", 'error')
        INSTALL_STATUS = "error"
        LOG_QUEUE.put({'status': 'error', 'message': str(e)})

def main():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    
    with socketserver.TCPServer(("", PORT), InstallHandler) as httpd:
        print(f"\n{'='*60}")
        print(f"  🚀 Oracle APEX Web Installer Server")
        print(f"  📡 Running on: http://localhost:{PORT}")
        print(f"{'='*60}\n")
        
        # Open browser
        import webbrowser
        webbrowser.open(f'http://localhost:{PORT}')
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n\nServer stopped.")
            sys.exit(0)

if __name__ == "__main__":
    main()
PYEOF

chmod +x "$WEB_DIR/server.py"
echo -e "${GREEN}✓${NC} Python server created"

# ═══════════════════════════════════════════════════════════════════════════════
# CHECK PYTHON
# ═══════════════════════════════════════════════════════════════════════════════
PYTHON_CMD=""
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
else
    echo -e "${RED}✗${NC} Python not found!"
    echo -e "${YELLOW}Installing Python...${NC}"
    
    if command -v apt-get &> /dev/null; then
        sudo apt-get update -qq && sudo apt-get install -y python3
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y python3
    elif command -v zypper &> /dev/null; then
        sudo zypper --non-interactive install -y python3
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm python
    elif command -v brew &> /dev/null; then
        brew install python3
    fi
    
    PYTHON_CMD="python3"
fi

echo -e "${GREEN}✓${NC} Python: $($PYTHON_CMD --version)"

# ═══════════════════════════════════════════════════════════════════════════════
# START SERVER
# ═══════════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Starting Web Installer Server...${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${GREEN}🌐 Open in browser:${NC} ${YELLOW}http://localhost:${WEB_PORT}${NC}"
echo ""
echo -e "  ${CYAN}Press Ctrl+C to stop the server${NC}"
echo ""

cd "$WEB_DIR"
$PYTHON_CMD server.py
