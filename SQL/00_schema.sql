-- Para mantener una base de datos limpia, en caso de fallas.

DROP TABLE IF EXISTS login_auditory;

-- Creación de tabla para los usuarios.

CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	username VARCHAR(100) UNIQUE NOT NULL,
	password VARCHAR(100) NOT NULL
);

-- Creación de tabla para analizar intentos de login.

CREATE TABLE login_auditory (
    id_audi SERIAL PRIMARY KEY,
    user_tried VARCHAR(100),
    date_try TIMESTAMP DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'America/Bogota'),
    state VARCHAR(20)
);