---
icon: lucide/database
---

# Guía rápida de SQLite desde la terminal

Objetivo: aprender a crear bases de datos, gestionar tablas y ejecutar consultas SQL usando `sqlite3` directamente desde la terminal, sin necesidad de interfaces gráficas ni código Python.

## 1. Instalar y abrir SQLite

Comprueba si tienes SQLite instalado:

```bash
sqlite3 --version
```

```bash
which sqlite3
```

Si no está instalado:

=== "Debian / Ubuntu"

    ```bash
    sudo apt install sqlite3
    ```

=== "macOS con Homebrew"

    ```bash
    brew install sqlite
    ```

## 2. Crear una base de datos

Desde la terminal, ejecuta:

```bash
sqlite3 empresa.db
```

Esto abre la consola interactiva de SQLite y crea el archivo `empresa.db` si todavía no existe.

Verás un indicador similar a:

```text
SQLite version ...
Enter ".help" for usage hints.
sqlite>
```

A partir de aquí puedes escribir comandos SQL directamente.

Para salir:

```text
.quit
```

También puedes usar `.exit`.

Importante: los comandos que empiezan por un punto, como `.tables` o `.schema`, son comandos propios de la consola SQLite, no instrucciones SQL.

## 3. Crear una tabla

Dentro de `sqlite3`, ejecuta:

```sql
CREATE TABLE usuarios (
    id INTEGER PRIMARY KEY,
    nombre TEXT NOT NULL,
    edad INTEGER,
    email TEXT UNIQUE
);
```

Para comprobar que se ha creado:

```text
.tables
```

Para ver su definición:

```text
.schema usuarios
```

## 4. Insertar datos

```sql
INSERT INTO usuarios (nombre, edad, email)
VALUES ('Ana', 25, 'ana@example.com');

INSERT INTO usuarios (nombre, edad, email)
VALUES ('Luis', 30, 'luis@example.com');

INSERT INTO usuarios (nombre, edad, email)
VALUES ('Marta', 22, 'marta@example.com');
```

Cada sentencia SQL debe terminar con `;` para ejecutarse correctamente en la consola interactiva.

## 5. Consultar información

Mostrar todos los usuarios:

```sql
SELECT * FROM usuarios;
```

Mostrar solo algunas columnas:

```sql
SELECT nombre, email
FROM usuarios;
```

Filtrar por edad:

```sql
SELECT *
FROM usuarios
WHERE edad >= 25;
```

Ordenar de mayor a menor edad:

```sql
SELECT *
FROM usuarios
ORDER BY edad DESC;
```

Limitar los resultados:

```sql
SELECT *
FROM usuarios
LIMIT 2;
```

### Mejorar la presentación de los resultados

En la consola SQLite puedes utilizar estos comandos:

```text
.headers on
.mode column
```

A partir de ese momento, las consultas se mostrarán con nombres de columnas y un formato tabular más legible.

Otros formatos útiles:

```text
.mode table
.mode csv
.mode json
```

La disponibilidad de algunos modos depende de la versión de SQLite.

## 6. Actualizar y eliminar registros

Modificar la edad de Ana:

```sql
UPDATE usuarios
SET edad = 26
WHERE nombre = 'Ana';
```

Eliminar un usuario por su identificador:

```sql
DELETE FROM usuarios
WHERE id = 2;
```

Comprueba el resultado:

```sql
SELECT * FROM usuarios;
```

Precaución: no olvides `WHERE` en un `UPDATE` o `DELETE`, salvo que quieras afectar a todas las filas.

## 7. Añadir columnas y eliminar tablas

Añadir una columna:

```sql
ALTER TABLE usuarios
ADD COLUMN activo INTEGER DEFAULT 1;
```

Eliminar una tabla completa:

```sql
DROP TABLE usuarios;
```

`DROP TABLE` elimina tanto la estructura como los datos de la tabla.

## 8. Consultas de resumen o agregados

Contar usuarios:

```sql
SELECT COUNT(*) FROM usuarios;
```

Calcular la edad media:

```sql
SELECT AVG(edad) FROM usuarios;
```

Obtener la edad máxima:

```sql
SELECT MAX(edad) FROM usuarios;
```

Agrupar usuarios por edad:

```sql
SELECT edad, COUNT(*) AS cantidad
FROM usuarios
GROUP BY edad;
```

## 9. Ejecutar comandos directamente desde la terminal

No es obligatorio entrar en el modo interactivo. Puedes ejecutar una consulta desde tu terminal habitual.

Mostrar todas las tablas:

```bash
sqlite3 empresa.db ".tables"
```

Consultar todos los usuarios:

```bash
sqlite3 empresa.db "SELECT * FROM usuarios;"
```

Consultar con encabezados y columnas:

```bash
sqlite3 -header -column empresa.db \
"SELECT id, nombre, edad FROM usuarios;"
```

Insertar un registro:

```bash
sqlite3 empresa.db \
"INSERT INTO usuarios (nombre, edad, email)
 VALUES ('Carlos', 28, 'carlos@example.com');"
```

Exportar el resultado de una consulta a CSV:

```bash
sqlite3 -header -csv empresa.db \
"SELECT * FROM usuarios;" > usuarios.csv
```

Esto crea `usuarios.csv` en el directorio actual.

## 10. Importar un archivo SQL

Si tienes un archivo `datos.sql` con instrucciones SQL, puedes ejecutarlo así:

```bash
sql empresa.db < datos.sql
```sql

También puedes importar el contenido de un archivo SQL desde dentro de la consola:

```text
.reatos.sql
```sql

## 11. Comandos propios de la consola SQLite

Estos son los comandos que conviene memorizar:

| Comando | Función |
| --- | --- |
| `.help` | Muestra la ayuda |
| `.databases` | Muestra las bases de datos abiertas |
| `.tables` | Lista las tablas |
| `.schema` | Muestra las estructuras |
| `.schema usuarios` | Muestra la estructura de una tabla |
| `.headers on` | Activa los encabezados |
| `.mode column` | Presenta los resultados en columnas |
| `.mode csv` | Presenta los resultados como CSV |
| `.read archivo.sql` | Ejecuta un archivo SQL |
| `.backup copia.db` | Crea una copia de seguridad |
| `.quit` | Sale de SQLite |

## 12. Ejercicio completo para practicar

Puedes seguir este recorrido desde una terminal:

```bash
sqlite3 practica.db
```

Después, copia las siguientes instrucciones dentro de SQLite:

```sql
CREATE TABLE productos (
    id INTEGER PRIMARY KEY,
    nombre TEXT NOT NULL,
    precio REAL NOT NULL
);

INSERT INTO productos (nombre, precio)
VALUES
    ('Teclado', 29.99),
    ('Ratón', 15.50),
    ('Monitor', 199.99);

SELECT * FROM productos;

SELECT nombre, precio
FROM productos
WHERE precio > 20
ORDER BY precio DESC;

UPDATE productos
SET precio = 25.99
WHERE nombre = 'Teclado';

SELECT COUNT(*) AS total_productos
FROM productos;
```

Para terminar:

```text
.quit
```

La base de datos queda guardada en `practica.db`, por lo que puedes volver a abrirla cuando quieras:

```bash
sqlite3 practica.db
```

## Chuleta final

Desde tu terminal habitual

```bash
sqlite3 empresa.db
sqlite3 empresa.db ".tables"
sqlite3 empresa.db "SELECT * FROM usuarios;"
sqlite3 -header -column empresa.db "SELECT * FROM usuarios;"
```

Dentro de `sqlite3`

```sql
.help
.tables
.schema
SELECT * FROM usuarios;
.backup copia.db
.quit
```

Regla para recordar: los comandos con punto gestionan la consola; las instrucciones SQL gestionan los datos. Con `sqlite3`, un archivo `.db` y estas operaciones básicas ya puedes empezar a trabajar con bases de datos desde la terminal.
