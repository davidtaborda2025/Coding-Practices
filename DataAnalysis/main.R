library(DBI)
library(RPostgres)
library(ggplot2)

con <- dbConnect(RPostgres::Postgres(),
                 dbname = 'test_db', host = 'localhost', port = 5432,
                 user = 'administrador_db',
                 password = 'password123')

datos_auditoria <- dbReadTable(con, "login_auditory")
dbDisconnect(con)

grafica <- ggplot(datos_auditoria, aes(x = state, fill = state)) + geom_bar() +
  labs(title = "Analisis de Intentos de Login", subtitle = "Datos obtenidos en tiempo real desde PostgreSQL",
       x = "Estado del Intento", y = "Cantidad de Registros") + theme_minimal() +
  scale_fill_manual(values = c("FALLO" = "#e74c3c", "EXITO" = "#2ecc71"))

print("--- DATOS RECUPERADOS DESDE DOCKER ---")
print(datos_auditoria)

print(grafica)

ggsave("../Python/Python/static/reporte_auditoria.png", plot = grafica, width = 8, height = 6, dpi = 100)