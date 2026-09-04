library(DBI)
library(RPostgres)
library(ggplot2)
library(scales)
library(urltools)

db_url <- trimws(Sys.getenv("DATABASE_URL"))

if (db_url != "") {
  # Normalizar esquema
  if (grepl("^postgres://", db_url)) {
    db_url <- sub("^postgres://", "postgresql://", db_url)
  }

  # Extraer componentes mediante urltools
  parsed_url <- url_parse(db_url)

  # Extraer credenciales (usuario:password)
  user_info <- strsplit(parsed_url$user, ":")[[1]]
  db_user <- user_info[1]
  db_pass <- ifelse(length(user_info) > 1, user_info[2], "")

  # Extraer nombre de la BD eliminando el slash inicial
  raw_path <- parsed_url$path
  db_name <- gsub("^/", "", strsplit(raw_path, "\\?")[[1]][1])

  # Host y puerto con fallbacks por defecto de Postgres
  db_host <- parsed_url$domain
  db_port <- ifelse(!is.na(parsed_url$port) && parsed_url$port != "", as.integer(parsed_url$port), 5432)

  # Conexión TCP con cifrado SSL explícito hacia Neon.tech
  con <- dbConnect(RPostgres::Postgres(),
                   host = db_host,
                   port = db_port,
                   user = db_user,
                   password = db_pass,
                   dbname = db_name,
                   sslmode = "require")
} else {
  con <- dbConnect(RPostgres::Postgres(),
                   dbname = 'test_db', host = 'localhost', port = 5432,
                   user = 'administrador_db',
                   password = 'password123')
}

datos_auditoria <- dbReadTable(con, "login_auditory")
dbDisconnect(con)

conteo <- table(datos_auditoria$state)
max_registros <- if(length(conteo) > 0) max(conteo) else 1

grafica <- ggplot(datos_auditoria, aes(x = state, fill = state)) + geom_bar(width = 0.6) +
  labs(title = "Analisis de Intentos de Login", subtitle = "Datos obtenidos en tiempo real desde PostgreSQL",
       x = "Estado del Intento", y = "Cantidad de Registros") + theme_minimal() +
  scale_fill_manual(values = c("FALLO" = "#e74c3c", "EXITO" = "#2ecc71")) +
  scale_y_continuous(breaks = seq(0, max_registros, by = 1)) +
  theme(plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
        plot.subtitle = element_text(size = 12, hjust = 0.5), plot.margin = margin(20, 40, 20, 20),
        axis.title.x = element_text(margin = margin(t = 15)), axis.title.y = element_text(margin = margin(r = 15)),
        legend.position = "right", panel.grid.minor = element_blank())

args <- commandArgs(trailingOnly = TRUE)
ruta_final <- if(length(args) > 0) args[1] else "Python/Python/static/reporte_auditoria.png"

ggsave(ruta_final, plot = grafica, width = 9, height = 7, dpi = 120)