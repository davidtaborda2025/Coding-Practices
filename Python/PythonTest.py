# Prueba de la función zip().

nombres = ['David', 'Juan', 'María', 'Alejandro', 'Isabella']
asientos = ['A1', 'A2', 'A3', 'A4', 'A5']
estados = ['Reservado', 'Libre', 'Reservado', 'Ocupado', 'Libre']

sala = list(zip(nombres, asientos, estados))

print(sala)