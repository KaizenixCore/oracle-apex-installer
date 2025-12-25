cat > web-installer.py << 'ENDOFFILE'
#!/usr/bin/env python3
import asyncio
import json
import os
from aiohttp import web
import aiohttp_cors

os.environ['TERM'] = 'xterm-256color'
os.environ['LANG'] = 'C.UTF-8'
os.environ['LC_ALL'] = 'C.UTF-8'

HOST = '0.0.0.0'
PORT = 8888

class InstallManager:
    def __init__(self):
        self.websockets = set()
        self.is_installing = False
        self.logs = []
        
    async def broadcast(self, msg):
        for ws in self.websockets:
            try:
                await ws.send_json(msg)
            except:
                pass
    
    async def run_cmd(self, cmd):
        env = os.environ.copy()
        env['TERM'] = 'xterm-256color'
        env['DEBIAN_FRONTEND'] = 'noninteractive'
        
        proc = await asyncio.create_subprocess_shell(
            cmd,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.STDOUT,
            env=env
        )
        
        while True:
            line = await proc.stdout.readline()
            if not line:
                break
            text = line.decode('utf-8', errors='replace').strip()
            if text:
                self.logs.append(text)
                await self.broadcast({'type': 'log', 'data': text})
        
        await proc.wait()
        return proc.returncode
    
    async def install(self, db_pwd, apex_pwd):
        if self.is_installing:
            return
        
        self.is_installing = True
        self.logs = []
        
        try:
            await self.broadcast({'type': 'step', 'data': '🚀 Starting installation...'})
            
            # Download installer
            await self.broadcast({'type': 'step', 'data': '📥 Downloading installer...'})
            url = "https://raw.githubusercontent.com/KaizenixCore/oracle-apex-installer/main/oracle-apex-installer.sh"
            ret = await self.run_cmd(f"curl -fsSL {url} -o /tmp/install.sh && chmod +x /tmp/install.sh")
            
            if ret != 0:
                await self.broadcast({'type': 'error', 'data': '❌ Failed to download installer'})
                return
            
            await self.broadcast({'type': 'log', 'data': '✅ Installer downloaded'})
            
            # Show instructions
            await self.broadcast({'type': 'log', 'data': ''})
            await self.broadcast({'type': 'log', 'data': '═══════════════════════════════════════════════════════'})
            await self.broadcast({'type': 'log', 'data': '  ✅ PREPARATION COMPLETE!'})
            await self.broadcast({'type': 'log', 'data': '═══════════════════════════════════════════════════════'})
            await self.broadcast({'type': 'log', 'data': ''})
            await self.broadcast({'type': 'log', 'data': '  To complete installation, run this on your HOST system:'})
            await self.broadcast({'type': 'log', 'data': ''})
            await self.broadcast({'type': 'log', 'data': '  cd ~ && rm -rf oracle-apex-complete'})
            await self.broadcast({'type': 'log', 'data': f'  export ORACLE_PASSWORD="{db_pwd}"'})
            await self.broadcast({'type': 'log', 'data': f'  export APEX_ADMIN_PASSWORD="{apex_pwd}"'})
            await self.broadcast({'type': 'log', 'data': '  curl -fsSL https://raw.githubusercontent.com/KaizenixCore/oracle-apex-installer/main/oracle-apex-installer.sh -o install.sh'})
            await self.broadcast({'type': 'log', 'data': '  chmod +x install.sh && bash install.sh'})
            await self.broadcast({'type': 'log', 'data': ''})
            await self.broadcast({'type': 'log', 'data': '═══════════════════════════════════════════════════════'})
            
            await self.broadcast({'type': 'complete', 'data': '✅ Ready! Follow instructions above.'})
            
        except Exception as e:
            await self.broadcast({'type': 'error', 'data': f'❌ Error: {str(e)}'})
        finally:
            self.is_installing = False

manager = InstallManager()

HTML = '''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Oracle APEX Web Installer</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box}
        body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;background:linear-gradient(135deg,#667eea,#764ba2);min-height:100vh;padding:20px;color:#fff}
        .container{max-width:900px;margin:0 auto}
        header{text-align:center;padding:30px 0}
        h1{font-size:2.2em;margin-bottom:10px;text-shadow:2px 2px 4px rgba(0,0,0,.3)}
        .logo{font-size:4em;margin-bottom:10px}
        .box{background:#fff;color:#1e1e1e;padding:35px;border-radius:15px;box-shadow:0 15px 50px rgba(0,0,0,.3);margin-bottom:25px}
        .form-group{margin-bottom:20px}
        label{display:block;font-weight:600;margin-bottom:8px;color:#667eea}
        input{width:100%;padding:14px;border:2px solid #ddd;border-radius:8px;font-size:1em}
        input:focus{outline:none;border-color:#667eea}
        .btn{width:100%;padding:16px;border:none;border-radius:10px;font-size:1.1em;font-weight:600;cursor:pointer;background:linear-gradient(135deg,#667eea,#764ba2);color:#fff;transition:transform .2s}
        .btn:hover{transform:translateY(-2px)}
        .btn:disabled{opacity:.6;cursor:not-allowed;transform:none}
        .terminal{background:#1e1e1e;color:#0f0;padding:20px;border-radius:10px;font-family:'Courier New',monospace;font-size:.9em;height:350px;overflow-y:auto;margin-top:20px;display:none}
        .terminal.show{display:block}
        .terminal-line{margin-bottom:4px;word-wrap:break-word}
        .status{background:rgba(102,126,234,.1);padding:12px;border-radius:8px;margin-bottom:15px;display:none}
        .status.show{display:block}
        .dot{display:inline-block;width:10px;height:10px;border-radius:50%;margin-right:8px}
        .dot.running{background:#f59e0b;animation:pulse 1.5s infinite}
        .dot.success{background:#10b981}
        .dot.error{background:#ef4444}
        @keyframes pulse{0%,100%{opacity:1}50%{opacity:.5}}
        .alert{padding:15px;border-radius:8px;margin-bottom:15px}
        .alert-success{background:rgba(16,185,129,.15);border-left:4px solid #10b981}
        .alert-error{background:rgba(239,68,68,.15);border-left:4px solid #ef4444}
        .conn{position:fixed;top:15px;right:15px;padding:8px 15px;border-radius:15px;background:rgba(255,255,255,.2);backdrop-filter:blur(10px);font-size:.85em}
    </style>
</head>
<body>
    <div class="conn"><span class="dot" id="connDot"></span><span id="connText">Connecting...</span></div>
    <div class="container">
        <header>
            <div class="logo">🚀</div>
            <h1>Oracle APEX Web Installer</h1>
            <p style="opacity:.9;margin-top:8px">KaizenixCore v3.2</p>
        </header>
        <div class="box">
            <div id="form">
                <h2 style="color:#667eea;margin-bottom:25px">⚙️ Configuration</h2>
                <div class="form-group">
                    <label>🔐 Database Password</label>
                    <input type="password" id="dbPwd" placeholder="Min 8 characters">
                </div>
                <div class="form-group">
                    <label>🔑 APEX Admin Password</label>
                    <input type="password" id="apexPwd" placeholder="Min 8 characters">
                </div>
                <button class="btn" id="startBtn" onclick="start()">🚀 Start</button>
            </div>
            <div class="status" id="status">
                <span class="dot" id="statusDot"></span>
                <span id="statusText">Ready</span>
            </div>
            <div id="alerts"></div>
            <div class="terminal" id="term"><div id="termContent"></div></div>
        </div>
    </div>
    <script>
        let ws;
        function connect(){
            ws=new WebSocket('ws://'+location.hostname+':8888/ws');
            ws.onopen=()=>{document.getElementById('connDot').className='dot success';document.getElementById('connText').textContent='Connected'};
            ws.onmessage=e=>{const m=JSON.parse(e.data);handle(m)};
            ws.onerror=()=>{document.getElementById('connDot').className='dot error';document.getElementById('connText').textContent='Error'};
            ws.onclose=()=>{document.getElementById('connDot').className='dot error';document.getElementById('connText').textContent='Disconnected';setTimeout(connect,3000)}
        }
        function handle(m){
            if(m.type==='log'||m.type==='step'){appendLog(m.data);if(m.type==='step')document.getElementById('statusText').textContent=m.data}
            else if(m.type==='complete'){showAlert('success',m.data);document.getElementById('statusDot').className='dot success';document.getElementById('statusText').textContent='Complete!'}
            else if(m.type==='error'){showAlert('error',m.data);document.getElementById('statusDot').className='dot error';document.getElementById('statusText').textContent='Failed'}
        }
        function start(){
            const db=document.getElementById('dbPwd').value,apex=document.getElementById('apexPwd').value;
            if(!db||!apex){alert('Enter both passwords');return}
            if(db.length<8||apex.length<8){alert('Passwords must be 8+ chars');return}
            document.getElementById('form').style.display='none';
            document.getElementById('status').classList.add('show');
            document.getElementById('term').classList.add('show');
            document.getElementById('statusDot').className='dot running';
            document.getElementById('statusText').textContent='Installing...';
            document.getElementById('termContent').innerHTML='';
            ws.send(JSON.stringify({action:'start_install',db_password:db,apex_password:apex}))
        }
        function appendLog(t){
            const term=document.getElementById('termContent'),line=document.createElement('div');
            line.className='terminal-line';line.textContent=t;term.appendChild(line);
            document.getElementById('term').scrollTop=document.getElementById('term').scrollHeight
        }
        function showAlert(type,msg){
            const div=document.createElement('div');div.className='alert alert-'+type;
            div.innerHTML='<strong>'+(type==='success'?'✅':'❌')+' '+msg+'</strong>';
            document.getElementById('alerts').appendChild(div)
        }
        window.onload=connect
    </script>
</body>
</html>'''

async def index(req):
    return web.Response(text=HTML, content_type='text/html')

async def ws_handler(req):
    ws = web.WebSocketResponse()
    await ws.prepare(req)
    manager.websockets.add(ws)
    try:
        for log in manager.logs:
            await ws.send_json({'type': 'log', 'data': log})
        async for msg in ws:
            if msg.type == web.WSMsgType.TEXT:
                data = json.loads(msg.data)
                if data['action'] == 'start_install':
                    asyncio.create_task(manager.install(data['db_password'], data['apex_password']))
    finally:
        manager.websockets.discard(ws)
    return ws

app = web.Application()
cors = aiohttp_cors.setup(app, defaults={"*": aiohttp_cors.ResourceOptions(allow_credentials=True, expose_headers="*", allow_headers="*")})
app.router.add_get('/', index)
app.router.add_get('/ws', ws_handler)
for route in list(app.router.routes()):
    cors.add(route)

if __name__ == '__main__':
    print("="*50)
    print("  🚀 Oracle APEX Web Installer v3.2")
    print("  Open: http://localhost:8888")
    print("="*50)
    web.run_app(app, host=HOST, port=PORT, print=None)
ENDOFFILE
