---
icon: lucide/database
---

# Guía rápida de SQLite desde la terminal

Esta guía explica cómo crear una base de datos, definir y modificar tablas, insertar y consultar datos, y paginar resultados con `sqlite3` desde la terminal. No necesitas una interfaz gráfica ni escribir código Python.

Los ejemplos usan una base de datos llamada `empresa.db` y una tabla `usuarios`. Puedes ejecutarlos en orden o adaptarlos a tus propios datos.

## 1. Instalar y abrir SQLite

Comprueba si SQLite está instalado:

```bash
sqlite3 --version
```

También puedes comprobar la ruta del ejecutable:

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

!!! tip "macOS"
    macOS suele incluir SQLite de serie. Homebrew instala una versión más reciente si necesitas funciones modernas como `ALTER TABLE ... DROP COLUMN`.

## 2. Crear una base de datos

Abre la base de datos desde la terminal:

```bash
sqlite3 empresa.db
```

Esto abre la consola interactiva de SQLite y crea el archivo `empresa.db` si todavía no existe. Verás un indicador similar a:

```text
SQLite version ...
Enter ".help" for usage hints.
sqlite>
```

A partir de aquí puedes escribir sentencias SQL directamente.

Para salir de la consola:

```text
.quit
```

También puedes usar `.exit`.

!!! note "Comandos con punto"
    Los comandos que empiezan por punto, como `.tables`, `.schema` o `.quit`, son propios de la consola de SQLite. No son SQL y no necesitan terminar en `;`.

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

`INTEGER PRIMARY KEY` identifica cada fila de forma única y SQLite genera el valor automáticamente cuando no lo indicas. En la mayoría de los casos no necesitas añadir `AUTOINCREMENT`.

Comprueba que la tabla se ha creado:

```text
.tables
```

Para ver su definición:

```text
.schema usuarios
```

También puedes consultar las columnas, sus tipos y sus restricciones con:

```sql
PRAGMA table_info(usuarios);
```

## 4. Insertar datos

Inserta varios registros en una sola sentencia:

```sql
INSERT INTO usuarios (nombre, edad, email)
VALUES
    ('Ana', 25, 'ana@example.com'),
    ('Luis', 30, 'luis@example.com'),
    ('Marta', 22, 'marta@example.com'),
    ('Carlos', 28, 'carlos@example.com'),
    ('Elena', 30, 'elena@example.com'),
    ('Pablo', 25, 'pablo@example.com'),
    ('Lucía', 22, 'lucia@example.com'),
    ('Diego', 35, 'diego@example.com');
```

Si prefieres insertar de uno en uno, repite el `INSERT` por cada fila.

Cada sentencia SQL debe terminar en `;` para ejecutarse correctamente en la consola interactiva.

!!! note "Guardado automático"
    SQLite trabaja en modo `autocommit` por defecto: cada sentencia se guarda al terminar. Si abres una transacción con `BEGIN`, debes cerrarla con `COMMIT` o deshacerla con `ROLLBACK`.

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

En consultas reales conviene indicar las columnas que necesitas en lugar de usar `*`.

Filtrar por edad:

```sql
SELECT *
FROM usuarios
WHERE edad >= 25;
```

Ordenar de mayor a menor edad:

```sql
SELECT id, nombre, edad
FROM usuarios
ORDER BY edad DESC, nombre ASC;
```

`DESC` ordena de forma descendente y `ASC` de forma ascendente. Si no indicas nada, se usa `ASC`. Añadir `nombre` como segundo criterio sirve para desempatar cuando dos personas tienen la misma edad.

Limitar el número de resultados:

```sql
SELECT id, nombre, edad
FROM usuarios
ORDER BY edad DESC, nombre ASC
LIMIT 3;
```

`LIMIT 3` devuelve como máximo tres filas. Para recorrer un resultado por lotes no basta con `LIMIT`; lo veremos en la sección de paginación.

Buscar por texto con `LIKE`:

```sql
SELECT id, nombre, email
FROM usuarios
WHERE nombre LIKE 'A%';
```

`LIKE` permite usar dos comodines:

| Comodín | Significado |
| --- | --- |
| `%` | Cualquier secuencia de caracteres, incluida una secuencia vacía |
| `_` | Exactamente un carácter |

Algunos ejemplos:

```sql
-- Correos del dominio example.com
SELECT nombre, email
FROM usuarios
WHERE email LIKE '%@example.com';

-- Nombres que contienen una "a"
SELECT nombre
FROM usuarios
WHERE nombre LIKE '%a%';

-- Nombres de tres letras que empiezan por "A" y terminan en "a"
SELECT nombre
FROM usuarios
WHERE nombre LIKE 'A_a';

-- Nombres que no empiezan por "A"
SELECT nombre
FROM usuarios
WHERE nombre NOT LIKE 'A%';
```

Por defecto, `LIKE` no distingue mayúsculas de minúsculas en texto ASCII, así que `LIKE 'a%'` también encuentra `Ana`. Tampoco normaliza los acentos: `'o'` no coincide con `'ó'`.

### Mejorar la presentación de los resultados

En la consola de SQLite puedes activar los encabezados y el formato de columnas:

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

La disponibilidad de algunos modos depende de la versión de SQLite. Para volver al formato básico puedes usar `.mode list` y `.headers off`.

## 6. Paginar resultados por lotes

`LIMIT` por sí solo no pagina: únicamente recorta el resultado. Para recorrer una tabla por lotes necesitas:

1. un `ORDER BY` estable, por ejemplo `ORDER BY id`;
2. un tamaño de lote, que se indica con `LIMIT`;
3. una forma de saber dónde empieza el siguiente lote: `OFFSET` o un cursor.

### 6.1. Paginación con LIMIT y OFFSET

La forma más sencilla es usar `LIMIT` para el tamaño del lote y `OFFSET` para saltar las filas de los lotes anteriores:

```sql
-- Lote 1: filas 1 a 3
SELECT id, nombre, edad
FROM usuarios
ORDER BY id
LIMIT 3 OFFSET 0;

-- Lote 2: filas 4 a 6
SELECT id, nombre, edad
FROM usuarios
ORDER BY id
LIMIT 3 OFFSET 3;

-- Lote 3: filas 7 a 8
SELECT id, nombre, edad
FROM usuarios
ORDER BY id
LIMIT 3 OFFSET 6;
```

La fórmula para calcular el desplazamiento es:

```text
OFFSET = (número_de_lote - 1) * tamaño_del_lote
```

| Lote | `LIMIT` | `OFFSET` |
| --- | --- | --- |
| 1 | 3 | 0 |
| 2 | 3 | 3 |
| 3 | 3 | 6 |
| 4 | 3 | 9 |

Con los ocho usuarios de ejemplo, el lote 4 estaría vacío; la tabla muestra la fórmula general.

!!! warning "El orden importa"
    Sin `ORDER BY`, SQLite no garantiza el orden de las filas. Un mismo registro podría aparecer en dos lotes o no aparecer en ninguno.

`OFFSET` es cómodo para saltar a una página concreta, pero se vuelve lento con valores grandes porque SQLite debe leer y descartar todas las filas anteriores.

### 6.2. Paginación por cursor o keyset

La paginación por cursor sigue usando `LIMIT` para fijar el tamaño del lote, pero evita `OFFSET`. En lugar de saltar filas, guarda el último valor del lote anterior y pide las filas que van después. Normalmente se usa la clave primaria:

```sql
-- Primer lote
SELECT id, nombre, edad
FROM usuarios
ORDER BY id
LIMIT 3;

-- Siguiente lote: el último id del lote anterior fue 3
SELECT id, nombre, edad
FROM usuarios
WHERE id > 3
ORDER BY id
LIMIT 3;
```

Este método suele ser más eficiente porque aprovecha el índice de la clave primaria y no tiene que recorrer las filas descartadas. Su limitación es que no permite saltar directamente a la página 10; hay que avanzar lote a lote.

Si ordenas por una columna que no es única, incluye también el `id` para desempatar. Por ejemplo, si el último registro del lote anterior fue `edad = 25` e `id = 6`:

```sql
SELECT id, nombre, edad
FROM usuarios
WHERE (edad, id) > (25, 6)
ORDER BY edad, id
LIMIT 3;
```

La comparación de tuplas requiere SQLite 3.15 o superior.

Para paginar de más reciente a más antiguo, invierte la comparación. Si el primer lote devolvió los ids `8`, `7` y `6`, el siguiente lote continúa después del `6`:

```sql
-- Primer lote
SELECT id, nombre, edad
FROM usuarios
ORDER BY id DESC
LIMIT 3;

-- Siguiente lote: continúa después del id 6
SELECT id, nombre, edad
FROM usuarios
WHERE id < 6
ORDER BY id DESC
LIMIT 3;
```

### 6.4. ¿Qué estrategia usar?

| Estrategia | Ventaja | Limitación |
| --- | --- | --- |
| `LIMIT` + `OFFSET` | Es sencilla y permite saltar a una página concreta | Se vuelve lenta con desplazamientos grandes y puede repetir u omitir filas si los datos cambian |
| Cursor o keyset | Es rápida y estable para recorrer muchos datos | No permite saltar directamente a una página arbitraria |

En cualquier caso, usa siempre un `ORDER BY` que incluya una columna única, como `id`, para que el orden sea estable.

## 7. Consultas de resumen o agregados

Contar usuarios:

```sql
SELECT COUNT(*) AS total_usuarios
FROM usuarios;
```

Con los datos de ejemplo devuelve `8`.

Calcular la edad media:

```sql
SELECT ROUND(AVG(edad), 2) AS edad_media
FROM usuarios;
```

Con los datos de ejemplo devuelve `27.13`.

Obtener la edad mínima y la máxima:

```sql
SELECT MIN(edad) AS edad_minima,
       MAX(edad) AS edad_maxima
FROM usuarios;
```

Agrupar usuarios por edad:

```sql
SELECT edad, COUNT(*) AS cantidad
FROM usuarios
GROUP BY edad
ORDER BY edad;
```

Filtrar los grupos con `HAVING`:

```sql
SELECT edad, COUNT(*) AS cantidad
FROM usuarios
GROUP BY edad
HAVING COUNT(*) >= 2
ORDER BY cantidad DESC, edad ASC;
```

Con los datos de ejemplo devuelve las edades que se repiten al menos dos veces: `22`, `25` y `30`.

La diferencia entre `WHERE` y `HAVING` es importante:

- `WHERE` filtra filas antes de agrupar.
- `HAVING` filtra grupos después de calcular el agregado.

Puedes combinar ambos:

```sql
SELECT edad, COUNT(*) AS cantidad
FROM usuarios
WHERE edad >= 25
GROUP BY edad
HAVING COUNT(*) >= 2
ORDER BY cantidad DESC, edad ASC;
```

## 8. Actualizar y eliminar registros

Modificar la edad de Ana:

```sql
UPDATE usuarios
SET edad = 26
WHERE nombre = 'Ana';
```

Actualizar varios valores a la vez:

```sql
UPDATE usuarios
SET nombre = 'Ana Torres', edad = 27
WHERE id = 1;
```

Eliminar un usuario por su identificador:

```sql
DELETE FROM usuarios
WHERE id = 2;
```

Comprueba el resultado:

```sql
SELECT *
FROM usuarios;
```

!!! warning "No olvides el WHERE"
    Un `UPDATE` o un `DELETE` sin `WHERE` afecta a todas las filas de la tabla. Antes de ejecutar un cambio masivo, comprueba el filtro con un `SELECT` y haz una copia de seguridad.

Desde la consola de SQLite puedes crear una copia antes de un cambio delicado:

```text
.backup empresa_antes.db
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
 VALUES ('Carmen', 31, 'carmen@example.com');"
```

Exportar el resultado de una consulta a CSV:

```bash
sqlite3 -header -csv empresa.db \
"SELECT * FROM usuarios;" > usuarios.csv
```

Esto crea `usuarios.csv` en el directorio actual. Las comillas dobles permiten pasar la consulta como un solo argumento; dentro de SQL, los textos van entre comillas simples.

## 10. Importar un archivo SQL

Si tienes un archivo `datos.sql` con instrucciones SQL, puedes ejecutarlo sobre la base de datos así:

```bash
sqlite3 empresa.db < datos.sql
```

Si quieres que el proceso se detenga en el primer error, añade `-bail`:

```bash
sqlite3 -bail empresa.db < datos.sql
```

También puedes importar el contenido desde dentro de la consola:

```text
.read datos.sql
```

`.read` busca el archivo en el directorio desde el que abriste SQLite. Después de importarlo, puedes seguir escribiendo consultas en la consola.

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
| `.mode table` | Presenta los resultados como tabla |
| `.mode csv` | Presenta los resultados como CSV |
| `.mode json` | Presenta los resultados como JSON |
| `.read archivo.sql` | Ejecuta un archivo SQL |
| `.backup copia.db` | Crea una copia de seguridad |
| `.quit` | Sale de SQLite |

Recuerda que estos comandos no llevan `;` y no son instrucciones SQL.

## 12. Modificar la estructura de una tabla

SQLite permite añadir, renombrar y eliminar columnas, además de renombrar tablas. No permite cambiar el tipo de una columna directamente con `ALTER TABLE`; para eso hay que reconstruir la tabla.

| Operación | Orden | Disponibilidad |
| --- | --- | --- |
| Añadir una columna | `ALTER TABLE ... ADD COLUMN ...` | Todas las versiones |
| Renombrar una columna | `ALTER TABLE ... RENAME COLUMN ... TO ...` | SQLite 3.25 o superior |
| Renombrar una tabla | `ALTER TABLE ... RENAME TO ...` | Todas las versiones |
| Eliminar una columna | `ALTER TABLE ... DROP COLUMN ...` | SQLite 3.35 o superior |
| Cambiar el tipo | Reconstruir la tabla | — |

Comprueba tu versión con `sqlite3 --version` antes de usar las operaciones más recientes.

Los siguientes ejemplos continúan con la tabla `usuarios` de las secciones anteriores.

### Añadir una columna

```sql
ALTER TABLE usuarios
ADD COLUMN activo INTEGER NOT NULL DEFAULT 1;
```

Los registros existentes reciben el valor `1`. Si añades una columna `NOT NULL` a una tabla que ya tiene datos, debes indicar un `DEFAULT`.

### Renombrar una columna

```sql
ALTER TABLE usuarios
RENAME COLUMN nombre TO nombre_completo;
```

A partir de este momento, las consultas deben usar el nuevo nombre:

```sql
SELECT id, nombre_completo, edad
FROM usuarios;
```

### Renombrar una tabla

```sql
ALTER TABLE usuarios
RENAME TO clientes;
```

La tabla y sus datos se conservan; solo cambia el nombre. El archivo `empresa.db` no cambia de nombre. A partir de aquí debes usar `clientes` en las consultas y en tus scripts. Si tienes triggers o vistas, revísalos para comprobar que siguen funcionando.

### Eliminar una columna

```sql
ALTER TABLE clientes
DROP COLUMN activo;
```

Esta operación requiere SQLite 3.35 o superior. No se puede eliminar una columna que forme parte de la clave primaria, tenga una restricción `UNIQUE`, esté indexada o se use en una clave foránea, un `CHECK`, un trigger o una vista.

### Cambiar el tipo de una columna

SQLite no tiene una orden `ALTER TABLE ... ALTER COLUMN`. Para cambiar el tipo de una columna o una restricción, hay que crear una tabla nueva, copiar los datos, eliminar la original y renombrar la nueva.

??? example "Ejemplo: cambiar `edad` de INTEGER a TEXT"

    ```sql
    BEGIN;

    CREATE TABLE clientes_nueva (
        id INTEGER PRIMARY KEY,
        nombre_completo TEXT NOT NULL,
        edad TEXT,
        email TEXT UNIQUE
    );

    INSERT INTO clientes_nueva (id, nombre_completo, edad, email)
    SELECT id, nombre_completo, CAST(edad AS TEXT), email
    FROM clientes;

    DROP TABLE clientes;
    ALTER TABLE clientes_nueva RENAME TO clientes;

    COMMIT;
    ```

    Antes de hacerlo, ejecuta `.backup clientes_antes.db` y revisa los índices, triggers y claves foráneas. Si algo falla, usa `ROLLBACK` en lugar de `COMMIT`.

### Eliminar una tabla

```sql
DROP TABLE clientes;
```

`DROP TABLE` elimina tanto la estructura como todos los datos de la tabla. No se puede deshacer si no tienes una copia de seguridad. Si quieres evitar un error cuando la tabla no existe, usa:

```sql
DROP TABLE IF EXISTS clientes;
```

Si solo quieres vaciar la tabla pero conservar su estructura, usa `DELETE FROM clientes;`. SQLite no tiene la orden `TRUNCATE`.

## 13. Ejercicio completo para practicar

Crea una base de datos nueva:

```bash
sqlite3 practica.db
```

Dentro de SQLite, ejecuta:

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
    ('Monitor', 199.99),
    ('Altavoces', 45.00),
    ('Webcam', 59.90),
    ('Hub USB', 24.99);
```

Practica las consultas:

```sql
SELECT * FROM productos;

SELECT nombre, precio
FROM productos
WHERE precio > 20
ORDER BY precio DESC;

-- "Ratón" no aparece: la "ó" no coincide con "o"
SELECT nombre, precio
FROM productos
WHERE nombre LIKE '%o%';

SELECT COUNT(*) AS total_productos,
       ROUND(AVG(precio), 2) AS precio_medio
FROM productos;
```

Pagina los resultados en lotes de dos:

```sql
SELECT id, nombre, precio
FROM productos
ORDER BY id
LIMIT 2 OFFSET 0;

SELECT id, nombre, precio
FROM productos
ORDER BY id
LIMIT 2 OFFSET 2;
```

También puedes practicar la paginación por cursor. Este lote continúa después del `id = 2`:

```sql
SELECT id, nombre, precio
FROM productos
WHERE id > 2
ORDER BY id
LIMIT 2;
```

Modifica y elimina datos:

```sql
UPDATE productos
SET precio = 27.99
WHERE nombre = 'Teclado';

DELETE FROM productos
WHERE nombre = 'Ratón';
```

Practica los cambios de estructura:

```sql
ALTER TABLE productos
ADD COLUMN stock INTEGER NOT NULL DEFAULT 0;

ALTER TABLE productos
RENAME COLUMN precio TO precio_eur;

ALTER TABLE productos
RENAME TO articulos;

SELECT * FROM articulos;
```

Para terminar:

```text
.quit
```

La base de datos queda guardada en `practica.db`, por lo que puedes volver a abrirla cuando quieras:

```bash
sqlite3 practica.db
```

Si quieres repetir el ejercicio desde cero, ejecuta `DROP TABLE articulos;` o borra el archivo `practica.db`.

## Chuleta final

Los nombres de bases de datos, tablas y archivos son ejemplos; adáptalos a tu caso. Los bloques de esta chuleta son independientes entre sí, así que no hace falta ejecutarlos todos seguidos.

### Desde la terminal

```bash
sqlite3 empresa.db
sqlite3 empresa.db ".tables"
sqlite3 empresa.db "SELECT * FROM usuarios;"
sqlite3 -header -column empresa.db "SELECT * FROM usuarios;"
sqlite3 empresa.db < datos.sql
```

### Dentro de `sqlite3`

```text
.help
.tables
.schema usuarios
.headers on
.mode column
.read datos.sql
.backup copia.db
.quit
```

### Paginación por lotes

```sql
-- Lote 2, con 10 filas (OFFSET = 10)
SELECT id, nombre
FROM usuarios
ORDER BY id
LIMIT 10 OFFSET 10;

-- Siguiente lote con cursor (último id = 100)
SELECT id, nombre
FROM usuarios
WHERE id > 100
ORDER BY id
LIMIT 10;
```

### Cambios de estructura

```sql
ALTER TABLE usuarios ADD COLUMN activo INTEGER DEFAULT 1;
ALTER TABLE usuarios RENAME COLUMN nombre TO nombre_completo;
ALTER TABLE usuarios RENAME TO clientes;
ALTER TABLE clientes DROP COLUMN activo;

-- Solo si quieres eliminar la tabla y todos sus datos
DROP TABLE clientes;
```

Regla para recordar: los comandos con punto gestionan la consola; las instrucciones SQL gestionan los datos y la estructura.

Antes de un `UPDATE` o un `DELETE`, ejecuta primero un `SELECT` con el mismo `WHERE`; antes de un `DROP` o de un cambio de estructura, haz una copia con `.backup`.
