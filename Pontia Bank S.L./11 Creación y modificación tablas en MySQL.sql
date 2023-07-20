
USE banco;

#TRANSACCIONES
SELECT count(*) FROM transaccion;
SELECT * FROM transaccion;

#CLIENTES
SELECT * FROM clientes;
SELECT count(*) FROM clientes;

#FRAUDE
SELECT * FROM fraude;
SELECT count(*) FROM fraude;

#BALANCES
SELECT * FROM balances;
SELECT count(*) FROM balances;

# ALTERAR TABLAS
#TRANSACCION
ALTER TABLE transaccion
MODIFY t_id int;

ALTER TABLE transaccion
MODIFY tiempo datetime;

ALTER TABLE transaccion
MODIFY tipo varchar(20);

ALTER TABLE transaccion
MODIFY monto decimal(10,2);

#BALANCES

ALTER TABLE balances
MODIFY t_id int;

ALTER TABLE balances
MODIFY balance_prev_or decimal(15,2);

ALTER TABLE balances
MODIFY balance_post_or decimal(15,2);

ALTER TABLE balances
MODIFY balance_prev_des decimal(15,2);

ALTER TABLE balances
MODIFY balance_post_des decimal(15,2);

#FRAUDE
ALTER TABLE fraude
MODIFY t_id int;

ALTER TABLE fraude
MODIFY es_fraude bit(1);

ALTER TABLE fraude
MODIFY mensaje_alarma varchar(20);

#CLIENTES
ALTER TABLE clientes
MODIFY t_id int;

ALTER TABLE clientes
MODIFY cl_origen varchar(20);

ALTER TABLE clientes
MODIFY cl_destino varchar(20);


#FOREING KEY AND PRIMARY KEY

ALTER TABLE transaccion
ADD PRIMARY KEY (t_id);

ALTER TABLE clientes
ADD PRIMARY KEY (t_id);

ALTER TABLE fraude
ADD PRIMARY KEY (t_id);

ALTER TABLE balances
ADD PRIMARY KEY (t_id);

ALTER TABLE fraude
ADD CONSTRAINT fk_fraude
foreign key (t_id)
references transaccion(t_id);

ALTER TABLE balances
ADD CONSTRAINT fk_balances
foreign key (t_id)
references transaccion(t_id);

ALTER TABLE clientes
ADD CONSTRAINT fk_cliente
foreign key (t_id)
references transaccion(t_id);

