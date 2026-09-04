library(DBI)
library(RPostgres)
library(ggplot2)
library(scales)

db_url <- trimws(Sys.getenv("DATABASE_URL"))

if (db_url != "") {
  patron <- "^postgres(?:ql)?://([^:]+):([^@]+)@([^:/]+)(?::(\\d+))?/([^?]+)"
  matches <- regmatches(db_url, regexec(patron, db_url, perl = TRUE))[[1]]

  if (length(matches) >= 6) {
    db_user <- matches[2]
    db_pass <- matches[3]
    db_host <- matches[4]
    db_port <- if (matches[5] != "") as.integer(matches[5]) else 5432
    db_name <- matches[6]

    con <- dbConnect(RPostgres::Postgres(),
                     host = db_host,
                     port = db_port,
                     user = db_user,
                     password = db_pass,
                     dbname = db_name,
                     sslmode = "require")
  } else {
    # Fallback si por alguna razón la URI difiere
    con <- dbConnect(RPostgres::Postgres(), dbname = db_url)
  }
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