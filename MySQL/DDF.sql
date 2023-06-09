CREATE DATABASE ddf;
USE ddf;

#DROP TABLE transacciones;
#DROP TABLE clientes;
#DROP TABLE fraude;
#DROP TABLE balances;

CREATE TABLE transacciones (
t_id TINYINT PRIMARY KEY NOT NULL,
tipo VARCHAR (20),
tiempo DATETIME,
cuantia DECIMAL (20,2)
);

CREATE TABLE clientes (
cl_origen VARCHAR (20),
cl_destino VARCHAR (20),
t_id TINYINT NOT NULL,
FOREIGN KEY (t_id) REFERENCES ddf.transacciones(t_id)
);

CREATE TABLE fraude (
alarma VARCHAR (20),
es_fraude BIT,
t_id TINYINT,
FOREIGN KEY (t_id) REFERENCES ddf.transacciones(t_id)
);

CREATE TABLE balances (
prev_origen DECIMAL (10,2),
post_origen DECIMAL (10,2),
prev_dest DECIMAL (10,2),
post_dest DECIMAL (10,2),
t_id TINYINT,
FOREIGN KEY (t_id) REFERENCES ddf.transacciones(t_id)
);









