cat > web-installer.py << 'PYEOF'
#!/usr/bin/env python3
"""
Oracle APEX Complete Web Installer - Backend Server
Created by: Peyman Rasouli - KaizenixCore
Version: 4.0.0
"""

import asyncio
import json
import os
import sys
from pathlib import Path
from aiohttp import web
import aiohttp_cors

# Configuration
HOST = '0.0.0.0'
PORT = 8888
PROJECT_DIR = Path('/root/oracle-apex-complete')

# Set environment variables
os.environ['TERM'] = 'xterm-256color'
os.environ['LANG'] = 'C.UTF-8'
os.environ['LC_ALL'] = 'C.UTF-8'
os.environ['DEBIAN_FRONTEND'] = 'noninteractive'

class InstallationManager:
    def __init__(self):
        self.process = None
        self.websockets = set()
        self.is_installing = False
        self.install_log = []
        
    async def broadcast(self, message):
        """Send message to all connected WebSocket clients"""
        disconnected = set()
        for ws in self.websockets:
            try:
                await ws.send_json(message)
            except Exception:
                disconnected.add(ws)
        self.websockets -= disconnected
    
    async def run_command(self, command, input_data=None):
        """Run shell command and stream output"""
        try:
            # Prepare environment
            cmd_env = os.environ.copy()
            cmd_env.update({
                'TERM': 'xterm-256color',
                'LANG': 'C.UTF-8',
                'LC_ALL': 'C.UTF-8',
                'DEBIAN_FRONTEND': 'noninteractive'
            })
            
            self.process = await asyncio.create_subprocess_shell(
                command,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.STDOUT,
                stdin=asyncio.subprocess.PIPE if input_data else None,
                env=cmd_env
            )
            
            # Send input if provided
            if input_data and self.process.stdin:
                self.process.stdin.write(input_data.encode())
                await self.process.stdin.drain()
                self.process.stdin.close()
            
            # Read output line by line
            while True:
                line = await self.process.stdout.readline()
                if not line:
                    break
                    
                output = line.decode('utf-8', errors='replace').rstrip()
                if output:
                    self.install_log.append(output)
                    await self.broadcast({
                        'type': 'log',
                        'data': output
                    })
            
            await self.process.wait()
            return self.process.returncode
            
        except Exception as e:
            error_msg = f"Command execution error: {str(e)}"
            self.install_log.append(error_msg)
            await self.broadcast({
                'type': 'error',
                'data': error_msg
            })
            return 1
    
    async def start_installation(self, db_password, apex_password):
        """Start Oracle APEX installation"""
        if self.is_installing:
            return {'error': 'Installation already in progress'}
        
        self.is_installing = True
        self.install_log = []
        
        try:
            await self.broadcast({
                'type': 'step',
                'data': '🚀 Starting Oracle APEX installation...'
            })
            
            # Step 1: Download installer
            await self.broadcast({
                'type': 'step',
                'data': '📥 Downloading Oracle APEX installer script...'
            })
            
            installer_url = "https://raw.githubusercontent.com/KaizenixCore/oracle-apex-installer/main/oracle-apex-installer.sh"
            download_cmd = f"curl -fsSL {installer_url} -o /tmp/install.sh && chmod +x /tmp/install.sh"
            
            returncode = await self.run_command(download_cmd)
            if returncode != 0:
                raise Exception("Failed to download installer script")
            
            await self.broadcast({
                'type': 'log',
                'data': '✅ Installer script downloaded successfully'
            })
            
            # Step 2: Prepare installation
            await self.broadcast({
                'type': 'step',
                'data': '🔐 Preparing installation with provided passwords...'
            })
            
            # Create password input (installer asks for passwords twice)
            password_input = f"{db_password}\n{db_password}\n{apex_password}\n{apex_password}\n"
            
            # Step 3: Run installer
            await self.broadcast({
                'type': 'step',
                'data': '⚙️ Running Oracle APEX installer (this may take 15-30 minutes)...'
            })
            
            await self.broadcast({
                'type': 'log',
                'data': ''
            })
            await self.broadcast({
                'type': 'log',
                'data': '═══════════════════════════════════════════════════════'
            })
            await self.broadcast({
                'type': 'log',
                'data': '  🚀 Oracle APEX Complete Installation Started'
            })
            await self.broadcast({
                'type': 'log',
                'data': '  Please wait... (15-30 minutes)'
            })
            await self.broadcast({
                'type': 'log',
                'data': '═══════════════════════════════════════════════════════'
            })
            await self.broadcast({
                'type': 'log',
                'data': ''
            })
            
            install_cmd = "bash /tmp/install.sh"
            returncode = await self.run_command(install_cmd, password_input)
            
            if returncode == 0:
                await self.broadcast({
                    'type': 'log',
                    'data': ''
                })
                await self.broadcast({
                    'type': 'log',
                    'data': '═══════════════════════════════════════════════════════'
                })
                await self.broadcast({
                    'type': 'log',
                    'data': '  ✅ Oracle APEX Installation Complete!'
                })
                await self.broadcast({
                    'type': 'log',
                    'data': '═══════════════════════════════════════════════════════'
                })
                await self.broadcast({
                    'type': 'log',
                    'data': ''
                })
                await self.broadcast({
                    'type': 'log',
                    'data': '📋 Access Information:'
                })
                await self.broadcast({
                    'type': 'log',
                    'data': '  • APEX Admin Panel: http://localhost:8080/ords/apex_admin'
                })
                await self.broadcast({
                    'type': 'log',
                    'data': '  • APEX Login Page: http://localhost:8080/ords/f?p=4550'
                })
                await self.broadcast({
                    'type': 'log',
                    'data': '  • Username: ADMIN'
                })
                await self.broadcast({
                    'type': 'log',
                    'data': f'  • Password: {apex_password}'
                })
                await self.broadcast({
                    'type': 'log',
                    'data': ''
                })
                
                await self.broadcast({
                    'type': 'complete',
                    'data': '✅ Oracle APEX installed successfully! You can now access it.'
                })
                return {'success': True}
            else:
                await self.broadcast({
                    'type': 'error',
                    'data': '❌ Installation failed. Please check the logs above for details.'
                })
                return {'success': False}
            
        except Exception as e:
            error_msg = f"Installation error: {str(e)}"
            await self.broadcast({
                'type': 'error',
                'data': error_msg
            })
            return {'error': error_msg}
        
        finally:
            self.is_installing = False
    
    async def get_status(self):
        """Get current installation status"""
        return {
            'is_installing': self.is_installing,
            'log_lines': len(self.install_log),
            'project_exists': PROJECT_DIR.exists()
        }

# Global installation manager
manager = InstallationManager()

# HTTP Handlers
async def index_handler(request):
    """Serve index.html"""
    html_file = Path(__file__).parent / 'web-installer.html'
    if html_file.exists():
        return web.FileResponse(html_file)
    
    # Fallback embedded HTML
    html = '''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Oracle APEX Web Installer</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #fff;
            min-height: 100vh;
            padding: 20px;
        }
        .container { max-width: 1000px; margin: 0 auto; }
        header { text-align: center; padding: 30px 0; }
        h1 { font-size: 2.5em; margin-bottom: 10px; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); }
        .logo { font-size: 4em; margin-bottom: 10px; }
        .box {
            background: rgba(255,255,255,0.98);
            color: #1e1e1e;
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.4);
            margin-bottom: 30px;
        }
        .form-group { margin-bottom: 25px; }
        label { display: block; font-weight: 600; margin-bottom: 8px; color: #667eea; }
        input {
            width: 100%;
            padding: 15px;
            border: 2px solid #ddd;
            border-radius: 10px;
            font-size: 1.1em;
            transition: border-color 0.3s;
        }
        input:focus { outline: none; border-color: #667eea; }
        .btn {
            padding: 18px 30px;
            border: none;
            border-radius: 12px;
            font-size: 1.2em;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            width: 100%;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
        }
        .btn:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
        }
        .btn:disabled { opacity: 0.6; cursor: not-allowed; }
        .terminal {
            background: #1e1e1e;
            color: #00ff00;
            padding: 20px;
            border-radius: 10px;
            font-family: 'Courier New', monospace;
            font-size: 0.95em;
            height: 400px;
            overflow-y: auto;
            margin-top: 20px;
            display: none;
        }
        .terminal.active { display: block; }
        .terminal-line { margin-bottom: 3px; word-wrap: break-word; }
        .status-bar {
            background: rgba(102, 126, 234, 0.1);
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
            display: none;
        }
        .status-bar.active { display: block; }
        .status-dot {
            display: inline-block;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            margin-right: 10px;
        }
        .status-running { background: #f59e0b; animation: pulse 1.5s infinite; }
        .status-success { background: #10b981; }
        .status-error { background: #ef4444; }
        @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
        .alert { padding: 20px; border-radius: 10px; margin-bottom: 20px; }
        .alert-success { background: rgba(16, 185, 129, 0.15); border-left: 4px solid #10b981; }
        .alert-error { background: rgba(239, 68, 68, 0.15); border-left: 4px solid #ef4444; }
        .conn-status {
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 10px 20px;
            border-radius: 20px;
            background: rgba(255,255,255,0.2);
            backdrop-filter: blur(10px);
        }
    </style>
</head>
<body>
    <div class="conn-status">
        <span class="status-dot" id="connDot"></span>
        <span id="connText">Connecting...</span>
    </div>
    <div class="container">
        <header>
            <div class="logo">🚀</div>
            <h1>Oracle APEX Web Installer</h1>
            <p style="opacity: 0.9; margin-top: 10px;">KaizenixCore v4.0 - Complete Browser Installation</p>
        </header>
        <div class="box">
            <div id="setupForm">
                <h2 style="color: #667eea; margin-bottom: 30px;">⚙️ Installation Configuration</h2>
                <div class="form-group">
                    <label for="dbPassword">🔐 Database Password (Oracle XE)</label>
                    <input type="password" id="dbPassword" placeholder="Enter password (min 8 chars)" required>
                    <small style="color: #666; display: block; margin-top: 8px;">Used for SYS and SYSTEM users</small>
                </div>
                <div class="form-group">
                    <label for="apexPassword">🔑 APEX Admin Password</label>
                    <input type="password" id="apexPassword" placeholder="Enter password (min 8 chars)" required>
                    <small style="color: #666; display: block; margin-top: 8px;">Used for APEX ADMIN user</small>
                </div>
                <button class="btn" id="startBtn" onclick="startInstall()">🚀 Start Complete Installation</button>
            </div>
            <div class="status-bar" id="statusBar">
                <span class="status-dot" id="statusDot"></span>
                <span id="statusText">Preparing...</span>
            </div>
            <div id="alertContainer"></div>
            <div class="terminal" id="terminal"><div id="terminalContent"></div></div>
        </div>
    </div>
    <script>
        let ws = null;
        
        function connect() {
            ws = new WebSocket(`ws://${window.location.hostname}:8888/ws`);
            
            ws.onopen = () => {
                document.getElementById('connDot').className = 'status-dot status-success';
                document.getElementById('connText').textContent = 'Connected';
            };
            
            ws.onmessage = (event) => {
                const msg = JSON.parse(event.data);
                handleMessage(msg);
            };
            
            ws.onerror = () => {
                document.getElementById('connDot').className = 'status-dot status-error';
                document.getElementById('connText').textContent = 'Error';
            };
            
            ws.onclose = () => {
                document.getElementById('connDot').className = 'status-dot status-error';
                document.getElementById('connText').textContent = 'Disconnected';
                setTimeout(connect, 3000);
            };
        }
        
        function handleMessage(msg) {
            switch(msg.type) {
                case 'log':
                case 'step':
                    appendLog(msg.data);
                    if(msg.type === 'step') {
                        document.getElementById('statusText').textContent = msg.data;
                    }
                    break;
                case 'complete':
                    showAlert('success', msg.data);
                    document.getElementById('statusDot').className = 'status-dot status-success';
                    document.getElementById('statusText').textContent = 'Complete!';
                    break;
                case 'error':
                    showAlert('error', msg.data);
                    document.getElementById('statusDot').className = 'status-dot status-error';
                    document.getElementById('statusText').textContent = 'Failed';
                    break;
            }
        }
        
        function startInstall() {
            const dbPwd = document.getElementById('dbPassword').value;
            const apexPwd = document.getElementById('apexPassword').value;
            
            if (!dbPwd || !apexPwd) {
                alert('Please enter both passwords');
                return;
            }
            
            if (dbPwd.length < 8 || apexPwd.length < 8) {
                alert('Passwords must be at least 8 characters');
                return;
            }
            
            document.getElementById('setupForm').style.display = 'none';
            document.getElementById('statusBar').classList.add('active');
            document.getElementById('terminal').classList.add('active');
            document.getElementById('statusDot').className = 'status-dot status-running';
            document.getElementById('statusText').textContent = 'Installing...';
            document.getElementById('terminalContent').innerHTML = '';
            
            ws.send(JSON.stringify({
                action: 'start_install',
                db_password: dbPwd,
                apex_password: apexPwd
            }));
        }
        
        function appendLog(text) {
            const terminal = document.getElementById('terminalContent');
            const line = document.createElement('div');
            line.className = 'terminal-line';
            line.textContent = text;
            terminal.appendChild(line);
            document.getElementById('terminal').scrollTop = document.getElementById('terminal').scrollHeight;
        }
        
        function showAlert(type, msg) {
            const alert = document.createElement('div');
            alert.className = `alert alert-${type}`;
            alert.innerHTML = `<strong>${type === 'success' ? '✅' : '❌'} ${msg}</strong>`;
            document.getElementById('alertContainer').appendChild(alert);
        }
        
        window.addEventListener('load', connect);
    </script>
</body>
</html>'''
    return web.Response(text=html, content_type='text/html')

async def websocket_handler(request):
    """WebSocket connection handler"""
    ws = web.WebSocketResponse()
    await ws.prepare(request)
    
    manager.websockets.add(ws)
    
    try:
        # Send current status
        await ws.send_json({
            'type': 'status',
            'data': await manager.get_status()
        })
        
        # Send existing logs
        for log_line in manager.install_log:
            await ws.send_json({
                'type': 'log',
                'data': log_line
            })
        
        # Listen for messages
        async for msg in ws:
            if msg.type == web.WSMsgType.TEXT:
                try:
                    data = json.loads(msg.data)
                    
                    if data['action'] == 'start_install':
                        db_password = data.get('db_password', '')
                        apex_password = data.get('apex_password', '')
                        
                        if not db_password or not apex_password:
                            await ws.send_json({
                                'type': 'error',
                                'data': 'Both passwords are required'
                            })
                            continue
                        
                        if len(db_password) < 8 or len(apex_password) < 8:
                            await ws.send_json({
                                'type': 'error',
                                'data': 'Passwords must be at least 8 characters'
                            })
                            continue
                        
                        # Start installation in background
                        asyncio.create_task(
                            manager.start_installation(db_password, apex_password)
                        )
                    
                    elif data['action'] == 'get_status':
                        status = await manager.get_status()
                        await ws.send_json({
                            'type': 'status',
                            'data': status
                        })
                
                except json.JSONDecodeError:
                    await ws.send_json({
                        'type': 'error',
                        'data': 'Invalid JSON message'
                    })
            
            elif msg.type == web.WSMsgType.ERROR:
                print(f'WebSocket error: {ws.exception()}')
    
    finally:
        manager.websockets.discard(ws)
    
    return ws

async def status_handler(request):
    """REST API status endpoint"""
    status = await manager.get_status()
    return web.json_response(status)

# Create application
app = web.Application()

# Setup CORS
cors = aiohttp_cors.setup(app, defaults={
    "*": aiohttp_cors.ResourceOptions(
        allow_credentials=True,
        expose_headers="*",
        allow_headers="*",
    )
})

# Add routes
app.router.add_get('/', index_handler)
app.router.add_get('/ws', websocket_handler)
app.router.add_get('/api/status', status_handler)

# Configure CORS on all routes
for route in list(app.router.routes()):
    cors.add(route)

if __name__ == '__main__':
    print("=" * 70)
    print("  🚀 Oracle APEX Complete Web Installer v4.0")
    print("=" * 70)
    print(f"  Server: http://localhost:{PORT}")
    print(f"  Open this URL in your browser to start installation")
    print("  Full installation will run inside container!")
    print("=" * 70)
    
    web.run_app(app, host=HOST, port=PORT, print=None)
PYEOF
