"""
Ejemplo de uso de la API del Panel Web
Este script muestra cómo interactuar con el panel web programáticamente
"""

import requests
import json

# Configuración
PANEL_URL = "http://localhost:8080"
PIN = "1823"

class PanelAPI:
    def __init__(self, base_url, pin):
        self.base_url = base_url
        self.pin = pin
        self.session = requests.Session()
        self.login()
    
    def login(self):
        """Iniciar sesión en el panel"""
        response = self.session.post(
            f"{self.base_url}/login",
            data={'pin': self.pin}
        )
        if response.json().get('success'):
            print("✅ Sesión iniciada correctamente")
        else:
            print("❌ Error al iniciar sesión")
            raise Exception("Login fallido")
    
    def crear_repositorio(self, nombre, contenido):
        """Crear un nuevo repositorio"""
        response = self.session.post(
            f"{self.base_url}/api/repos/create",
            json={'name': nombre, 'content': contenido}
        )
        return response.json()
    
    def listar_repositorios(self):
        """Listar todos los repositorios"""
        response = self.session.get(f"{self.base_url}/api/repos")
        return response.json()
    
    def eliminar_repositorio(self, repo_id):
        """Eliminar un repositorio"""
        response = self.session.delete(
            f"{self.base_url}/api/repos/{repo_id}/delete"
        )
        return response.json()
    
    def agregar_archivo(self, repo_id, filename, contenido):
        """Agregar archivo a un repositorio existente"""
        response = self.session.post(
            f"{self.base_url}/api/repos/{repo_id}/files",
            json={'filename': filename, 'content': contenido}
        )
        return response.json()
    
    def crear_usuario(self, username, password, dias=30):
        """Crear un usuario con contraseña"""
        response = self.session.post(
            f"{self.base_url}/api/users/add",
            json={
                'username': username,
                'password': password,
                'days': dias
            }
        )
        return response.json()
    
    def listar_usuarios(self):
        """Listar todos los usuarios"""
        response = self.session.get(f"{self.base_url}/api/users")
        return response.json()


def ejemplo_repositorios():
    """Ejemplo de uso de repositorios"""
    print("\n" + "="*50)
    print("EJEMPLO: Gestión de Repositorios")
    print("="*50 + "\n")
    
    # Inicializar API
    api = PanelAPI(PANEL_URL, PIN)
    
    # 1. Crear un repositorio con configuración de servidores
    print("1️⃣ Creando repositorio de configuración...")
    config_data = {
        "version": "1.0",
        "servidores": [
            {
                "nombre": "Servidor Principal",
                "ip": "192.168.1.100",
                "puerto": 5000,
                "activo": True
            },
            {
                "nombre": "Servidor Backup",
                "ip": "192.168.1.101",
                "puerto": 5000,
                "activo": False
            }
        ],
        "configuracion": {
            "timeout": 30,
            "reintentos": 3,
            "ssl": True
        }
    }
    
    resultado = api.crear_repositorio("Configuración Servidores", config_data)
    if resultado.get('success'):
        repo_id = resultado['repo_id']
        repo_url = resultado['url']
        print(f"✅ Repositorio creado!")
        print(f"   ID: {repo_id}")
        print(f"   URL: {PANEL_URL}{repo_url}")
        
        # 2. Agregar un archivo adicional al repositorio
        print("\n2️⃣ Agregando archivo de logs...")
        logs_data = {
            "logs": [
                {"fecha": "2026-03-05", "evento": "Servidor iniciado", "nivel": "info"},
                {"fecha": "2026-03-05", "evento": "Conexión establecida", "nivel": "info"}
            ]
        }
        api.agregar_archivo(repo_id, "logs.json", logs_data)
        print("✅ Archivo logs.json agregado")
        
        # 3. Listar todos los repositorios
        print("\n3️⃣ Listando repositorios...")
        repos = api.listar_repositorios()
        for rid, info in repos.items():
            print(f"   📦 {info['name']} - {PANEL_URL}{info['url']}")
            print(f"      Archivos: {', '.join(info['files'])}")
    else:
        print(f"❌ Error: {resultado.get('error')}")


def ejemplo_usuarios():
    """Ejemplo de uso de gestión de usuarios"""
    print("\n" + "="*50)
    print("EJEMPLO: Gestión de Usuarios")
    print("="*50 + "\n")
    
    # Inicializar API
    api = PanelAPI(PANEL_URL, PIN)
    
    # 1. Crear un usuario
    print("1️⃣ Creando usuario de prueba...")
    resultado = api.crear_usuario("usuario_test", "password123", dias=30)
    print(f"✅ {resultado.get('message', 'Usuario creado')}")
    
    # 2. Listar usuarios
    print("\n2️⃣ Listando usuarios...")
    usuarios = api.listar_usuarios()
    print(f"   Total de usuarios: {len(usuarios)}")
    for user in usuarios:
        print(f"   👤 {user['username']} - Expira: {user['expiry']}")


def ejemplo_completo():
    """Ejemplo completo de uso"""
    print("\n" + "="*50)
    print("EJEMPLO COMPLETO: Crear sistema de configuración")
    print("="*50 + "\n")
    
    api = PanelAPI(PANEL_URL, PIN)
    
    # Crear repositorio para cada tipo de configuración
    configs = [
        {
            "nombre": "Config VPN",
            "contenido": {
                "servidores_vpn": [
                    {"pais": "US", "ip": "vpn1.example.com", "puerto": 1194},
                    {"pais": "UK", "ip": "vpn2.example.com", "puerto": 1194}
                ]
            }
        },
        {
            "nombre": "Config DNS",
            "contenido": {
                "dns_primario": "8.8.8.8",
                "dns_secundario": "8.8.4.4",
                "dns_custom": ["1.1.1.1", "1.0.0.1"]
            }
        },
        {
            "nombre": "Config Proxy",
            "contenido": {
                "proxies": [
                    {"tipo": "http", "host": "proxy1.example.com", "puerto": 8080},
                    {"tipo": "socks5", "host": "proxy2.example.com", "puerto": 1080}
                ]
            }
        }
    ]
    
    print("Creando repositorios de configuración...\n")
    urls_generadas = []
    
    for config in configs:
        resultado = api.crear_repositorio(config["nombre"], config["contenido"])
        if resultado.get('success'):
            url = f"{PANEL_URL}{resultado['url']}"
            urls_generadas.append(url)
            print(f"✅ {config['nombre']}")
            print(f"   URL: {url}\n")
    
    print("\n" + "="*50)
    print("URLs GENERADAS (Compartir con usuarios):")
    print("="*50)
    for url in urls_generadas:
        print(f"🔗 {url}")
    print("="*50 + "\n")


if __name__ == "__main__":
    print("""
╔══════════════════════════════════════════════════╗
║     EJEMPLOS DE USO - PANEL WEB ELITE API       ║
╚══════════════════════════════════════════════════╝
    """)
    
    try:
        # Ejecutar ejemplos
        ejemplo_repositorios()
        print("\n" + "-"*50 + "\n")
        ejemplo_usuarios()
        print("\n" + "-"*50 + "\n")
        ejemplo_completo()
        
        print("\n✅ Todos los ejemplos ejecutados correctamente!")
        print("\n💡 Tip: Abre el panel web en http://localhost:8080 para ver los cambios")
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        print("\n⚠️  Asegúrate de que el panel web esté corriendo:")
        print("   python web_panel.py")
