#!/usr/bin/env python3
"""
Oracle APEX Web Installer - Backend Server
Created by: Peyman Rasouli - KaizenixCore
"""

import asyncio
import json
import os
import subprocess
import sys
from pathlib import Path
from aiohttp import web
import aiohttp_cors

# Configuration
HOST = '0.0.0.0'
PORT = 8888
PROJECT_DIR = Path.home() / 'oracle-apex-complete'

class InstallationManager:
    def __init__(self):
        self.process = None
        self.websockets = set()
        self.is_installing = False
        self.install_log = []
        
    async def broadcast(self, message):
        """Send message to all connected WebSocket clients"""
        if self.websockets:
            await asyncio.gather(
                *[ws.send_json(message) for ws in self.websockets],
                return_exceptions=True
            )
    
    async def run_command(self, command, cwd=None):
        """Run shell command and stream output"""
        try:
            self.process = await asyncio.create_subprocess_shell(
                command,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.STDOUT,
                stdin=asyncio.subprocess.PIPE,
                cwd=cwd
            )
            
            while True:
                line = await self.process.stdout.readline()
                if not line:
                    break
                    
                output = line.decode('utf-8', errors='replace').rstrip()
                self.install_log.append(output)
                
                await self.broadcast({
                    'type': 'log',
                    'data': output
                })
            
            await self.process.wait()
            return self.process.returncode
            
        except Exception as e:
            await self.broadcast({
                'type': 'error',
                'data': str(e)
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
                'type': 'status',
                'data': 'Starting installation...'
            })
            
            # Step 1: Download setup script
            await self.broadcast({
                'type': 'step',
                'data': 'Downloading installer...'
            })
            
            setup_url = "https://raw.githubusercontent.com/KaizenixCore/oracle-apex-installer/main/setup.sh"
            download_cmd = f"curl -fsSL {setup_url} -o /tmp/apex-setup.sh && chmod +x /tmp/apex-setup.sh"
            
            returncode = await self.run_command(download_cmd)
            if returncode != 0:
                raise Exception("Failed to download installer")
            
            # Step 2: Run installer with passwords
            await self.broadcast({
                'type': 'step',
                'data': 'Running installer...'
            })
            
            # Create password file
            password_file = PROJECT_DIR / '.passwords'
            PROJECT_DIR.mkdir(parents=True, exist_ok=True)
            
            with open(password_file, 'w') as f:
                f.write(f"{db_password}\n{apex_password}\n")
            
            # Run installer
            install_cmd = f"bash /tmp/apex-setup.sh < {password_file}"
            returncode = await self.run_command(install_cmd)
            
            # Cleanup password file
            password_file.unlink(missing_ok=True)
            
            if returncode == 0:
                await self.broadcast({
                    'type': 'complete',
                    'data': 'Installation completed successfully!'
                })
            else:
                await self.broadcast({
                    'type': 'error',
                    'data': 'Installation failed. Check logs for details.'
                })
            
            return {'success': returncode == 0}
            
        except Exception as e:
            await self.broadcast({
                'type': 'error',
                'data': str(e)
            })
            return {'error': str(e)}
        
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
    return web.FileResponse(html_file)

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
            if msg.type == aiohttp.WSMsgType.TEXT:
                data = json.loads(msg.data)
                
                if data['action'] == 'start_install':
                    db_password = data.get('db_password')
                    apex_password = data.get('apex_password')
                    
                    if not db_password or not apex_password:
                        await ws.send_json({
                            'type': 'error',
                            'data': 'Passwords are required'
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
            
            elif msg.type == aiohttp.WSMsgType.ERROR:
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
    print("  🚀 Oracle APEX Web Installer - Starting Server")
    print("=" * 70)
    print(f"  Server: http://localhost:{PORT}")
    print(f"  Open this URL in your browser to start installation")
    print("=" * 70)
    
    web.run_app(app, host=HOST, port=PORT)
