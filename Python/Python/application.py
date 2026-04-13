from flask import Flask, request, jsonify
from flask_cors import CORS
import psycopg2

app = Flask(__name__)
CORS(app)  # Hace la comunicación entre el front-end y el back-end.

# Configuraciones con Docker:

DB_PARAMS = {
    "host": "localhost",
    "database": "test_db",
    "user": "administrador_db",
    "password": "password123",
    "port": "5432"
}

# Nueva función para registro de intentos de login. Guarda cada intento para posterior análisis.

def registrar_auditoria(user, estado):
    try:
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()

        query = "INSERT INTO login_auditory (user_tried, state) VALUES (%s, %s)"
        cur.execute(query, (user, estado))
        conn.commit()
        cur.close()
        conn.close()

    except Exception as e:
        print(f"No se pudo registrar la auditoría: {e}")

@app.route('/login', methods=['POST'])
def login():
    datos = request.json
    user_web = datos.get('user')
    pass_web = datos.get('pass')

    try:
        conn = psycopg2.connect(**DB_PARAMS)
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
    app.run(debug=True, port=5000)