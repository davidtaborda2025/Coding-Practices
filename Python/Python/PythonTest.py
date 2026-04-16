"""
This script demonstrates several Python programming techniques, including working with lists, list comprehension,
and grouping elements based on certain characteristics. The provided code performs the following tasks:

1. Combines multiple lists into a single structured list of tuples using the `zip` function.
2. Filters elements in a list by creating new lists through list comprehensions.
3. Defines an empty structure for grouping purposes.

Modules or functions used are built-in and do not require external dependencies.
"""

"""
Prueba de la función zip().
"""

nombres = ['David', 'Juan', 'María', 'Alejandro', 'Isabella']
asientos = ['A1', 'A2', 'A3', 'A4', 'A5']
estados = ['Reservado', 'Libre', 'Reservado', 'Ocupado', 'Libre']

sala = list(zip(nombres, asientos, estados))

print(sala)

"""
Eliminar elementos de una lista con una expresión for.
"""

numeros = [2, 4, 2, 3, 1]

numeros = [x for x in numeros if x != 2] # Se genera un nuevo arreglo en este paso.

print(numeros)

numeros = [x for x in numeros if x % 2 == 0] # Aquí se hacen las modificaciones con el último arreglo (el de arriba).

print(numeros)

numeros = [x for x in numeros if x != 4] # La afectación es para el arreglo de la impresión más reciente.

print(numeros)

"""
Agrupación de elementos según característica.
"""

registrados = [{"name":"David", "city":"Cali"}, {"name":"Juan", "city":"Madrid"}, {"name":"María", "city":"París"},
               {"name":"Alejandro", "city":"Madrid"}, {"name":"Isabella", "city":"Cali"}]

agrupados = {} # Para conjunto vacío.

for registro in registrados:
    ciudad = registro["city"]

    if ciudad not in agrupados:
        agrupados[ciudad] = []

    agrupados[ciudad].append(registro["name"])

print(agrupados)