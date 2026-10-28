# Crear una tabla de canciones

```sql
CREATE TABLE canciones (
    id INTEGER PRIMARY KEY,
    nombre TEXT NOT NULL,
    duracion FLOAT NOT NULL
);
```

Para comprobar que se ha creado la tabla poner:

```sql
.tables
```

Para comprobar que contiene la tabla:

```sql
.schema canciones
```

# Para insertar datos en la tabla

## Se tienen que insertar unas 10 canciones

```sql
INSERT INTO canciones (nombre, duracion) VALUES ('Billie Jeans', 294), ('Take on me', 243), ('Everybody', 285), ('Thriller', 357), ('La gasolina', 192), ('I Want It That Way', 213), ('Macarena', 252), ('I love pdf', 248), ('Despacito', 229), ('Dynamite', 199);
```

Para ver la tabla se utiliza el siguiente comando:

```sql
SELECT * FROM canciones;
```

# Modificar

Para modificar el valor de una o varias canciones hay que hacer:

```sql
UPDATE canciones SET duracion = 600 WHERE nombre LIKE '%S';
```

# Filtrar

Para filtrar las canciones por la duración hay que poner:

```sql
SELECT nombre, duracion FROM canciones WHERE duracion >= 200;
```

Para buscar si una canción contiene la palabra 'love' hay que poner:

```sql
SELECT nombre FROM canciones WHERE nombre LIKE '%love%';
```

# Contar y media

Para contar cuantas canciones duran más de 200 segundos y hacer la media, poner:

```sql
SELECT COUNT(*) AS canciones_mas_de_200_s, AVG(duracion) AS media_duracion FROM canciones WHERE duracion >= 200;
```
