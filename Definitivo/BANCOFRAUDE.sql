USE banco;

#DROP TABLE transacciones;
#DROP TABLE clientes;
#DROP TABLE fraude;
#DROP TABLE balance

#TRANSACCIONES
SELECT count(*) FROM transaccion;
SELECT * FROM transaccion;
select * FROM transaccion WHERE tipo='DEBIT';
#CLIENTES
SELECT * FROM clientes;
SELECT count(*) FROM clientes;
#FRAUDE
SELECT * FROM fraude;
SELECT count(*) FROM fraude;
#BALANCES
SELECT * FROM balance;
SELECT count(*) FROM balance;

#TRANSACCIONES
ALTER TABLE transaccion
MODIFY tiempo datetime;

ALTER TABLE transaccion
MODIFY t_id int;

ALTER TABLE transaccion
MODIFY tipo varchar(20);

ALTER TABLE transaccion
MODIFY monto decimal(20,2);
#BALANCE
ALTER TABLE balance
MODIFY cliente varchar(20);

ALTER TABLE balance
MODIFY t_id int;

ALTER TABLE balance
MODIFY balance_prev decimal(20,2);

ALTER TABLE balance
MODIFY balance_post decimal(20,2);
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

ALTER TABLE balance
ADD CONSTRAINT fk_cliente
foreign key (t_id)
references clientes(t_id);

ALTER TABLE fraude
ADD CONSTRAINT fk_fraude
foreign key (t_id)
references transaccion(t_id);

ALTER TABLE balance
ADD CONSTRAINT fk_balance
foreign key (t_id)
references transaccion(t_id);

ALTER TABLE clientes
DROP foreign key fk_cliente;

#Cuestiones
#Prueba, el límite de pago con tarjeta de débito al mes es de 5000 euros.
select *
from transaccion;

select *
from clientes c
inner join balance b
on c.t_id= b.t_id
group by c.cl_origen;

#Calcular la media diaria del monto de las transacciones.

select avg(monto) as media_monto, date(tiempo) as fecha
from banco.transaccion
where month(tiempo)=9
group by date(tiempo);

select avg(monto) as media_monto, date(tiempo) as fecha
from banco.transaccion
where month(tiempo)=10
group by date(tiempo);

# se puede usar como alternativa day()#

#calcular la cuantia total de las transacciones
select sum(monto) as monto_total
from banco.transaccion;

#¿Cuáles son los 3 clientes con mejor balance a lo largo del mes (aquellos que al restarle al dinero recibido 
#el dinero enviado se quedan con un mejor resultado) y cuál ha sido su balance?
select c.cl_destino, b.balance_prev, b.balance_post, t.*
from banco.clientes c
inner join balance b
on c.t_id=b.t_id
inner join transaccion t
on b.t_id=t.t_id;

#que día del mes se han producido más transacciones y cuantas?
select count(t_id) as t_id_total, day(tiempo) as fecha
from banco.transaccion
where month(tiempo)=9
group by day(tiempo)
order by t_id_total desc;

select count(t_id) as t_id_total, day(tiempo) as fecha
from banco.transaccion
where month(tiempo)=10
group by day(tiempo)
order by t_id_total desc;

#a que hora del dia se producen mas transacciones y cuantas?
select count(t_id) as t_id_hora, date(tiempo) as hora
from banco.transaccion
group by date(tiempo)
order by t_id_hora desc;
#si tenemos en cuenta por mes es diferente
select count(t_id) as t_id_hora, hour(tiempo) as hora
from banco.transaccion
where month(tiempo)=10
group by hour(tiempo)
order by t_id_hora desc;

select count(t_id) as t_id_hora, hour(tiempo) as hora
from banco.transaccion
group by hour(tiempo)
order by hora desc;

select hour(tiempo)
from banco.transaccion
where month(tiempo)=9
order by tiempo desc;

#cuantas transacciones se producen por cada tipo de operación
select tipo, count(t_id) as cantidad_transacciones
from banco.transaccion
group by tipo;

#cual es el monto total de cada tipo de transaccion que realizan los 5 clientes que han transferido mas dinero
select tipo, count(monto) as monto_total
from banco.transaccion t
group by tipo;

#No se pueden producir varias transferencias que juntas sumen más de 3000€ en una misma hora.
select t_id, tiempo, monto
from banco.transaccion;

