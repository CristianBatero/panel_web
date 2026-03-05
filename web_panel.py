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
    WEB_CONFIG = {'host': '0.0.0.0', 'port': 8080, 'debug': True, 'secret_key': None}
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

def load_repos():
    if os.path.exists(REPOS_DB):
        with open(REPOS_DB, 'r', encoding='utf-8') as f:
            return json.load(f)
    return {}

def save_repos(repos):
    with open(REPOS_DB, 'w', encoding='utf-8') as f:
        json.dump(repos, f, indent=2, ensure_ascii=False)

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
        r = requests.get(f"{BASE_URL}/admin/users")
        return jsonify(r.json())
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/users/add', methods=['POST'])
@login_required
def add_user():
    try:
        data = request.json
        r = requests.post(f"{BASE_URL}/admin/add", json=data)
        return jsonify(r.json())
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/users/delete', methods=['POST'])
@login_required
def delete_user():
    try:
        username = request.json.get('username')
        # Implementar endpoint de eliminación
        return jsonify({'message': f'Usuario {username} eliminado'})
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
        days_to_add = data.get('days', 0)
        
        # Aquí debes implementar la lógica para renovar el usuario
        # Por ejemplo, obtener la fecha de expiración actual y sumar los días
        
        # Simulación de respuesta
        return jsonify({
            'success': True,
            'message': f'Usuario {username} renovado por {days_to_add} días adicionales'
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

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

# Vista pública de repositorio (sin autenticación)
@app.route('/repo/<repo_id>')
def view_repo(repo_id):
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
