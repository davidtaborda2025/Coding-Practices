from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
from apscheduler.schedulers.background import BackgroundScheduler
import psycopg2
import os
import subprocess

# Variables para el comportamiento online.

web_folder = os.path.join(os.getcwd(), 'Web')
base_dir = os.path.dirname(os.path.abspath(__file__))
templates_dir = os.path.join(base_dir, 'templates')
static_dir = os.path.join(base_dir, 'static')

app = Flask(__name__)
CORS(app)  # Hace la comunicación entre el front-end y el back-end.

def ejecutar_r():
    try:
        path_para_r = os.path.join(static_dir, "reporte_auditoria.png")
        subprocess.run(["Rscript", "DataAnalysis/main.R", path_para_r], check=True) # Para ejecutar R antes de mostrar el HTML.

    except Exception as e:
        print(f"Error ejecutando R: {e}")

scheduler = BackgroundScheduler()
scheduler.add_job(func=ejecutar_r, trigger="interval", minutes=3)
scheduler.add_job(func=ejecutar_r, trigger="date")
scheduler.start()

@app.route('/')
def index():
    return send_from_directory(web_folder, 'index.html')

@app.route('/<path:path>')
def serve_static(path):
    return send_from_directory(web_folder, path)

@app.route('/static/<path:filename>')
def serve_internal_static(filename):
    return send_from_directory(static_dir, filename)

# Configuración para funcionamiento online.

DATABASE_URL = os.getenv('DATABASE_URL') # Para obtener URL generada en línea.

def get_db_connection():
    if DATABASE_URL:
        return psycopg2.connect(DATABASE_URL)

    else:
        return psycopg2.connect(
            host="localhost",
            database="test_db",
            user="administrador_db",
            password="password123",
            port="5432"
        )

# Nueva función para registro de intentos de login. Guarda cada intento para posterior análisis.

def registrar_auditoria(user, estado):
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        query = "INSERT INTO login_auditory (user_tried, state) VALUES (%s, %s)"
        cur.execute(query, (user, estado))
        conn.commit()
        cur.close()
        conn.close()

    except Exception as e:
        print(f"No se pudo registrar la auditoría: {e}")

@app.route('/dashboard')
def dashboard():
    return send_from_directory(templates_dir, 'dashboard.html')

@app.route('/login', methods=['POST'])
def login():
    datos = request.json
    user_web = datos.get('user')
    pass_web = datos.get('pass')

    try:
        conn = get_db_connection()
        cur = conn.cursor()

        query = "SELECT * FROM users WHERE username = %s AND password = %s" # Para la consulta con BD.
        cur.execute(query, (user_web, pass_web))
        usuario_encontrado = cur.fetchone()

        cur.close()
        conn.close()

        if usuario_encontrado:
            registrar_auditoria(user_web, 'EXITO')
            return jsonify({"status": "success", "message": f"¡Bienvenido, {user_web}! Autenticado correctamente."})
        else:
            registrar_auditoria(user_web, 'FALLO')
            return jsonify({"status": "error", "message": "Credenciales incorrectas."})

    except psycopg2.Error as e:
        print(f"Error de base de datos: {e}")
        return jsonify({"status": "error", "message": "Fallo en la base de datos."}), 500

    except Exception as e:
        print(f"Error inesperado: {e}")
        return jsonify({"status": "error", "message": "Error interno del servidor."}), 500

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port)