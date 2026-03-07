from flask import Flask, render_template, request, jsonify, session, redirect, url_for, send_file
import requests
import secrets
import json
import os
from datetime import datetime, timedelta
from functools import wraps

# Importar configuración
try:
    from config import API_CONFIG, WEB_CONFIG, SECURITY_CONFIG, REPOS_CONFIG, UI_CONFIG
except ImportError:
    # Valores por defecto si no existe config.py
    API_CONFIG = {'base_url': 'http://localhost:5000', 'timeout': 10}
    WEB_CONFIG = {'host': '0.0.0.0', 'port': 5000, 'debug': False, 'secret_key': None}
    SECURITY_CONFIG = {'admin_pin': '1823', 'session_lifetime_hours': 2}
    REPOS_CONFIG = {'storage_dir': 'repositories', 'id_length': 8}
    UI_CONFIG = {'app_name': 'Panel Elite'}

app = Flask(__name__)
app.secret_key = WEB_CONFIG.get('secret_key') or secrets.token_hex(32)
app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(hours=SECURITY_CONFIG['session_lifetime_hours'])

# Configuración
BASE_URL = API_CONFIG['base_url']
ADMIN_PIN = SECURITY_CONFIG['admin_pin']
WEB_PORT = WEB_CONFIG['port']

# Directorio para repositorios
REPOS_DIR = REPOS_CONFIG['storage_dir']
os.makedirs(REPOS_DIR, exist_ok=True)

# Base de datos simple para repositorios
REPOS_DB = os.path.join(REPOS_DIR, "repos_db.json")
USERS_DB = os.path.join(REPOS_DIR, "users_db.json")

def load_repos():
    if os.path.exists(REPOS_DB):
        with open(REPOS_DB, 'r', encoding='utf-8') as f:
            return json.load(f)
    return {}

def save_repos(repos):
    with open(REPOS_DB, 'w', encoding='utf-8') as f:
        json.dump(repos, f, indent=2, ensure_ascii=False)

def load_users():
    if os.path.exists(USERS_DB):
        with open(USERS_DB, 'r', encoding='utf-8') as f:
            return json.load(f)
    return []

def save_users(users):
    with open(USERS_DB, 'w', encoding='utf-8') as f:
        json.dump(users, f, indent=2, ensure_ascii=False)

# Decorador para requerir autenticación
def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not session.get('authenticated'):
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

@app.route('/')
def index():
    if session.get('authenticated'):
        return redirect(url_for('dashboard'))
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        pin = request.form.get('pin')
        if pin == ADMIN_PIN:
            session['authenticated'] = True
            session.permanent = True
            return jsonify({'success': True})
        return jsonify({'success': False, 'message': 'PIN incorrecto'})
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

@app.route('/dashboard')
@login_required
def dashboard():
    return render_template('dashboard.html')

# API Endpoints para usuarios
@app.route('/api/users', methods=['GET'])
@login_required
def get_users():
    try:
        # Actualizar estado de usuarios antes de devolverlos
        update_users_status()
        users = load_users()
        return jsonify({'users': users})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/users/add', methods=['POST'])
@login_required
def add_user():
    try:
        data = request.json
        username = data.get('username')
        password = data.get('password')
        expiry_days = int(data.get('expiry_days', 30))
        user_type = data.get('type', 'premium')
        alias = data.get('alias', username)
        
        if not username or not password:
            return jsonify({'error': 'Usuario y contraseña son requeridos'}), 400
        
        users = load_users()
        
        # Verificar si el usuario ya existe
        if any(u['username'] == username for u in users):
            return jsonify({'error': 'El usuario ya existe'}), 400
        
        # Calcular fecha de expiración
        expiry_date = (datetime.now() + timedelta(days=expiry_days)).strftime('%Y-%m-%d')
        
        # Crear nuevo usuario
        new_user = {
            'username': username,
            'password': password,
            'alias': alias,
            'type': user_type,
            'status': 'activo',
            'expiry_date': expiry_date,
            'days_remaining': expiry_days,
            'created_at': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        }
        
        users.append(new_user)
        save_users(users)
        
        return jsonify({
            'success': True,
            'message': f'Usuario {username} creado exitosamente',
            'user': new_user
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/users/delete', methods=['POST'])
@login_required
def delete_user():
    try:
        username = request.json.get('username')
        
        if not username:
            return jsonify({'error': 'Usuario requerido'}), 400
        
        users = load_users()
        users = [u for u in users if u['username'] != username]
        save_users(users)
        
        return jsonify({
            'success': True,
            'message': f'Usuario {username} eliminado'
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/notify', methods=['POST'])
@login_required
def notify_user():
    try:
        data = request.json
        username = data.get('username')
        title = data.get('title')
        message = data.get('message')
        
        # Aquí puedes implementar la lógica de notificación
        # Por ejemplo, enviar push notification, email, etc.
        
        if username == 'all':
            return jsonify({'message': 'Notificación enviada a todos los usuarios'})
        else:
            return jsonify({'message': f'Notificación enviada a {username}'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/users/renew', methods=['POST'])
@login_required
def renew_user():
    try:
        data = request.json
        username = data.get('username')
        days_to_add = int(data.get('days', 0))
        
        if not username or days_to_add <= 0:
            return jsonify({'error': 'Usuario y días válidos son requeridos'}), 400
        
        users = load_users()
        user_found = False
        
        for user in users:
            if user['username'] == username:
                user_found = True
                
                # Calcular nueva fecha de expiración
                current_expiry = datetime.strptime(user['expiry_date'], '%Y-%m-%d')
                new_expiry = current_expiry + timedelta(days=days_to_add)
                user['expiry_date'] = new_expiry.strftime('%Y-%m-%d')
                
                # Calcular días restantes
                days_remaining = (new_expiry - datetime.now()).days
                user['days_remaining'] = max(0, days_remaining)
                
                # Actualizar estado
                if days_remaining > 0:
                    user['status'] = 'activo'
                
                break
        
        if not user_found:
            return jsonify({'error': 'Usuario no encontrado'}), 404
        
        save_users(users)
        
        return jsonify({
            'success': True,
            'message': f'Usuario {username} renovado por {days_to_add} días adicionales'
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

def update_users_status():
    """Actualiza el estado de los usuarios basado en su fecha de expiración"""
    try:
        users = load_users()
        updated = False
        
        for user in users:
            expiry_date = datetime.strptime(user['expiry_date'], '%Y-%m-%d')
            days_remaining = (expiry_date - datetime.now()).days
            user['days_remaining'] = max(0, days_remaining)
            
            # Actualizar estado
            old_status = user.get('status', 'activo')
            if days_remaining <= 0:
                user['status'] = 'expirado'
            else:
                user['status'] = 'activo'
            
            if old_status != user['status']:
                updated = True
        
        if updated:
            save_users(users)
    except Exception as e:
        print(f"Error actualizando estado de usuarios: {e}")

# Endpoints para repositorios
@app.route('/api/repos', methods=['GET'])
@login_required
def get_repos():
    repos = load_repos()
    return jsonify(repos)

@app.route('/api/repos/create', methods=['POST'])
@login_required
def create_repo():
    try:
        data = request.json
        name = data.get('name', 'repo')
        content = data.get('content', {})
        
        # Generar ID único
        repo_id = secrets.token_urlsafe(REPOS_CONFIG['id_length'])
        
        # Crear directorio del repositorio
        repo_path = os.path.join(REPOS_DIR, repo_id)
        os.makedirs(repo_path, exist_ok=True)
        
        # Guardar contenido JSON
        json_file = os.path.join(repo_path, 'data.json')
        with open(json_file, 'w', encoding='utf-8') as f:
            json.dump(content, f, indent=2, ensure_ascii=False)
        
        # Registrar en base de datos
        repos = load_repos()
        repos[repo_id] = {
            'name': name,
            'created': datetime.now().isoformat(),
            'url': f'/repo/{repo_id}',
            'files': ['data.json']
        }
        save_repos(repos)
        
        return jsonify({
            'success': True,
            'repo_id': repo_id,
            'url': f'/repo/{repo_id}',
            'message': 'Repositorio creado exitosamente'
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/repos/<repo_id>/delete', methods=['DELETE'])
@login_required
def delete_repo(repo_id):
    try:
        repos = load_repos()
        if repo_id not in repos:
            return jsonify({'error': 'Repositorio no encontrado'}), 404
        
        # Eliminar directorio
        repo_path = os.path.join(REPOS_DIR, repo_id)
        if os.path.exists(repo_path):
            import shutil
            shutil.rmtree(repo_path)
        
        # Eliminar de base de datos
        del repos[repo_id]
        save_repos(repos)
        
        return jsonify({'success': True, 'message': 'Repositorio eliminado'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/repos/<repo_id>/files', methods=['POST'])
@login_required
def add_file_to_repo(repo_id):
    try:
        repos = load_repos()
        if repo_id not in repos:
            return jsonify({'error': 'Repositorio no encontrado'}), 404
        
        data = request.json
        filename = data.get('filename', 'file.json')
        content = data.get('content', {})
        
        # Guardar archivo
        repo_path = os.path.join(REPOS_DIR, repo_id)
        file_path = os.path.join(repo_path, filename)
        
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(content, f, indent=2, ensure_ascii=False)
        
        # Actualizar registro
        if filename not in repos[repo_id]['files']:
            repos[repo_id]['files'].append(filename)
            save_repos(repos)
        
        return jsonify({'success': True, 'message': f'Archivo {filename} agregado'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Vista pública de repositorio (sin autenticación) - Devuelve JSON crudo
@app.route('/repo/<repo_id>')
def view_repo(repo_id):
    repos = load_repos()
    if repo_id not in repos:
        return jsonify({'error': 'Repositorio no encontrado'}), 404
    
    try:
        repo_path = os.path.join(REPOS_DIR, repo_id)
        files_data = {}
        
        for filename in repos[repo_id]['files']:
            file_path = os.path.join(repo_path, filename)
            if os.path.exists(file_path):
                with open(file_path, 'r', encoding='utf-8') as f:
                    files_data[filename] = json.load(f)
        
        # Si solo hay un archivo, devolver su contenido directamente
        if len(files_data) == 1:
            return jsonify(list(files_data.values())[0])
        
        # Si hay múltiples archivos, devolver todos
        return jsonify(files_data)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Vista HTML del repositorio (opcional)
@app.route('/repo/<repo_id>/view')
def view_repo_html(repo_id):
    repos = load_repos()
    if repo_id not in repos:
        return "Repositorio no encontrado", 404
    
    repo_info = repos[repo_id]
    return render_template('repo_view.html', repo_id=repo_id, repo_info=repo_info)

@app.route('/repo/<repo_id>/data')
def get_repo_data(repo_id):
    repos = load_repos()
    if repo_id not in repos:
        return jsonify({'error': 'Repositorio no encontrado'}), 404
    
    try:
        repo_path = os.path.join(REPOS_DIR, repo_id)
        files_data = {}
        
        for filename in repos[repo_id]['files']:
            file_path = os.path.join(repo_path, filename)
            if os.path.exists(file_path):
                with open(file_path, 'r', encoding='utf-8') as f:
                    files_data[filename] = json.load(f)
        
        return jsonify({
            'repo_info': repos[repo_id],
            'files': files_data
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    print(f"\n{'='*50}")
    print(f"🌐 {UI_CONFIG['app_name'].upper()} - PANEL WEB INICIADO")
    print(f"{'='*50}")
    print(f"📍 URL Local: http://localhost:{WEB_PORT}")
    print(f"📍 URL Red: http://0.0.0.0:{WEB_PORT}")
    print(f"🔑 PIN: {ADMIN_PIN}")
    print(f"📁 Repositorios: {REPOS_DIR}/")
    print(f"{'='*50}\n")
    app.run(
        host=WEB_CONFIG['host'], 
        port=WEB_CONFIG['port'], 
        debug=WEB_CONFIG['debug']
    )
