from flask import Flask, request, jsonify, render_template
from flask_cors import CORS
import psycopg2
import os
import subprocess

app = Flask(__name__, template_folder='templates', static_folder='static')
CORS(app)  # Hace la comunicación entre el front-end y el back-end.

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
    try:
        subprocess.run(["Rscript", "DataAnalysis/main.R"], check=True) # Para ejecutar R antes de mostrar el HTML.

    except Exception as e:
        print(f"Error ejecutando R: {e}")

    return render_template('dashboard.html')

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