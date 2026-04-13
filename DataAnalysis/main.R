library(DBI)
library(RPostgres)

con <- dbConnect(RPostgres::Postgres(),
                 dbname = 'test_db', host = 'localhost', port = 5432,
                 user = 'administrador_db',
                 password = 'password123')

datos_auditoria <- dbReadTable(con, "login_auditory")

print("--- DATOS RECUPERADOS DESDE DOCKER ---")
print(datos_auditoria)

dbDisconnect(con)