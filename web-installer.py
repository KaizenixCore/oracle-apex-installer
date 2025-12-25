#!/usr/bin/env python3
"""
Oracle APEX Web Installer - Backend Server
Created by: Peyman Rasouli - KaizenixCore
Version: 3.1.0
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
    
    async def run_command(self, command, cwd=None, input_data=None):
        """Run shell command and stream output"""
        try:
            self.process = await asyncio.create_subprocess_shell(
                command,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.STDOUT,
                stdin=asyncio.subprocess.PIPE if input_data else None,
                cwd=cwd
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
                'type': 'status',
                'data': 'Starting installation...'
            })
            
            # Step 1: Download installer
            await self.broadcast({
                'type': 'step',
                'data': '📥 Downloading Oracle APEX installer...'
            })
            
            installer_url = "https://raw.githubusercontent.com/KaizenixCore/oracle-apex-installer/main/oracle-apex-installer.sh"
            download_cmd = f"curl -fsSL {installer_url} -o /tmp/install.sh && chmod +x /tmp/install.sh"
            
            returncode = await self.run_command(download_cmd)
            if returncode != 0:
                raise Exception("Failed to download installer")
            
            await self.broadcast({
                'type': 'step',
                'data': '✅ Installer downloaded successfully'
            })
            
            # Step 2: Prepare password input
            await self.broadcast({
                'type': 'step',
                'data': '🔐 Preparing installation with provided passwords...'
            })
            
            # Create password input (2 passwords, each entered twice)
            password_input = f"{db_password}\n{db_password}\n{apex_password}\n{apex_password}\n"
            
            # Step 3: Run installer
            await self.broadcast({
                'type': 'step',
                'data': '🚀 Running Oracle APEX installer...'
            })
            
            await self.broadcast({
                'type': 'log',
                'data': '═══════════════════════════════════════════════════════'
            })
            await self.broadcast({
                'type': 'log',
                'data': '  Starting Oracle APEX Installation'
            })
            await self.broadcast({
                'type': 'log',
                'data': '  This may take 15-30 minutes...'
            })
            await self.broadcast({
                'type': 'log',
                'data': '═══════════════════════════════════════════════════════'
            })
            
            install_cmd = "bash /tmp/install.sh"
            returncode = await self.run_command(install_cmd, input_data=password_input)
            
            if returncode == 0:
                await self.broadcast({
                    'type': 'complete',
                    'data': '✅ Oracle APEX installed successfully!'
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
    if not html_file.exists():
        return web.Response(text="web-installer.html not found", status=404)
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
    print("  🚀 Oracle APEX Web Installer - Starting Server")
    print("=" * 70)
    print(f"  Server: http://localhost:{PORT}")
    print(f"  Open this URL in your browser to start installation")
    print("=" * 70)
    
    web.run_app(app, host=HOST, port=PORT, print=None)
