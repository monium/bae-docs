CREATE TABLE nombre (id INTEGER PRIMARY KEY, nombre TEXT NOT NULL);

INSERT INTO nombre (id, nombre) VALUES (1, "Rosa"), (2, "Carla"), (3, "Pedro");

CREATE TABLE apellido (id INTEGER PRIMARY KEY, apellido TEXT NOT NULL);

INSERT INTO apellido (id, apellido) VALUES (1, "Morales"), (2, "Perez"), (4,"Diaz");

SELECT * FROM nombre INNER JOIN apellido ON nombre.id = apellido.id;

-- Con esto conseguimos mostrar solo las filas en las que coincide el id con el nombre y el apellido