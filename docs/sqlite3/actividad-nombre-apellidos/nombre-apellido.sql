CREATE TABLE nombre (
    id INTEGER PRIMARY KEY,
    nombre TEXT NOT NULL
);

INSERT INTO TABLE nombre (nombre) VALUES ("Rosa", "Carla","Pedro")

CREATE TABLE apellido (
    id INTEGER PRIMARY KEY,
    apellido TEXT NOT NULL
);

INSERT INTO TABLE apellido (apellido) VALUES ("Morales","Perez","Diaz")

SELECT * FROM nombre INNER JOIN apellido ON nombre.id = apellido.id;

-- Con esto conseguimos mostrar solo las filas en las que coincide el id con el nombre y el apellido