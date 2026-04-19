library(DBI)
library(RPostgres)
library(ggplot2)
library(scales)

db_url <- Sys.getenv("DATABASE_URL")

if (db_url != "") {
  url_limpia <- gsub("postgresql://", "", db_url)
  usuario_pass <- strsplit(url_limpia, "@")[[1]][1]
  host_resto <- strsplit(url_limpia, "@")[[1]][2]

  user <- strsplit(usuario_pass, ":")[[1]][1]
  pass <- strsplit(usuario_pass, ":")[[1]][2]

  host_puerto <- strsplit(host_resto, "/")[[1]][1]
  db_name <- strsplit(host_resto, "/")[[1]][2]

  host <- strsplit(host_puerto, ":")[[1]][1]
  port <- strsplit(host_puerto, ":")[[1]][2]

  con <- dbConnect(RPostgres::Postgres(),
                   host = host,
                   port = as.integer(port),
                   user = user,
                   password = pass,
                   dbname = db_name)
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