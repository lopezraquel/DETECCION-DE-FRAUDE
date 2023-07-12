USE BANCO;

SELECT c.cl_origen, c.cl_destino, b.balance_prev, b.balance_post, t.*
FROM clientes c
INNER JOIN balance b
ON c.t_id=b.t_id
INNER JOIN transaccion t
ON b.t_id=t.t_id;

# 1. Calcular la media diaria de la monto de las transacciones.
select round(avg(monto),2) as media_monto, date(tiempo) as fecha 
from banco.transaccion where month(tiempo)=9 
group by date(tiempo);
select round(avg(monto),2) as media_monto, date(tiempo) as fecha 
from banco.transaccion where month(tiempo)=10 
group by date(tiempo);

# 2. Calcular la cuantía total de las transacciones.
select sum(monto) as monto_total
from banco.transaccion;

# 3. ¿Qué días del mes se han producido más transacciones y cuántas?
select count(t_id) as t_id_total, day(tiempo) as día
from transaccion
where month(tiempo)=9
group by day(tiempo)
order by t_id_total desc limit 1;

# 4. ¿A qué horas del día se producen más transacciones y cuántas?
select count(t_id) as total_transacciones_hora, hour(tiempo) as hora
from transaccion
where month(tiempo) = 9
group by hour(tiempo)
order by total_transacciones_hora desc;

# 5. ¿Cuáles son los 5 clientes que han transferido más dinero y cuánto?
select c.cl_origen, sum(t.monto) as monto_total
from transaccion t
inner join clientes c
on t.t_id= c.t_id
group by c.cl_origen
order by monto_total desc
limit 5;

# 6.  ¿Cuáles son los 5 clientes que han transferido menos dinero y cuánto?
select c.cl_origen, sum(t.monto) as monto_total
from transaccion t
inner join clientes c
on t.t_id= c.t_id
group by c.cl_origen
order by monto_total
limit 5;

# 7.  ¿Cuáles son los 10 clientes que han recibido más dinero y cuánto?
select sum(t.monto) as total_recibido, c.cl_destino
from transaccion t
inner join clientes c
on t.t_id= c.t_id
group by c.cl_destino
order by total_recibido desc
limit 10;

# 8.  ¿Cuáles son los 3 clientes con mejor balance a lo largo del mes (aquellos que al restarle al dinero recibido al
#  dinero enviado se quedan con un mejor resultado) y cuál ha sido su balance?
select c.cl_origen, sum(balance_post_or-balance_prev_or) as balance_total
from balances b
inner join transaccion t
on b.t_id= t.t_id
inner join clientes c
on t.t_id=c.t_id
group by c.cl_origen
order by balance_total desc
limit 3;

 
# 9.  ¿Cuáles son los 3 clientes con peor balance a lo largo de todo el mes y cuál ha sido?
select c.cl_origen, sum(balance_post_or-balance_prev_or) as balance_total
from balances b
inner join transaccion t
on b.t_id= t.t_id
inner join clientes c
on t.t_id=c.t_id
group by c.cl_origen
order by balance_total
limit 3;

# 10. ¿Cuántas transacciones fraudulentas se han producido?
SELECT COUNT(es_fraude) AS ‘total_fraude’
FROM fraude
WHERE es_fraude=1;

# 11. Diferenciando entre si las transacciones han producido una alarma de transacción fraudulenta en los sistemas, ¿cuántas han sido realmente fraudulentas y cuántas no?
# Transacciones que han hecho saltar mensaje alarma y SÍ han sido fraudulentas
SELECT COUNT(es_fraude) AS ‘true_fraude’
FROM fraude
WHERE es_fraude= 1 AND mensaje_alarma ='Detectado_fraude';

# Transacciones que han hecho saltar mensaje alarma y NO han sido fraudulentas
SELECT COUNT(es_fraude) AS ‘fake_fraude’
FROM fraude
WHERE es_fraude= 0 AND mensaje_alarma ='Detectado_fraude';

# Transacciones fraudulentas que NO han hecho saltar mensaje alarma
SELECT COUNT(es_fraude) AS ‘fraude_no_detectado’
FROM fraude
WHERE es_fraude= 1 AND mensaje_alarma ='No';

# 12. ¿Cuántas transacciones se producen por cada tipo de operación?
select tipo, count(t_id) as cantidad_transacciones
from transaccion
group by tipo;

# 13. ¿Cuál es la cuantía total de cada tipo de transacción que realizan los 5 clientes que han transferido más dinero?
select  c.cl_origen, t.tipo, sum(t.monto) as total_por_tipo_transaccion
from transaccion t
inner join clientes c
on t.t_id= c.t_id
group by c.cl_origen, t.tipo
order by total_por_tipo_transaccion desc
limit 5;

# 14. Para cada transacción, calcular el porcentaje de incremento del balance del destinatario
SELECT t_id,balance_prev_des,balance_post_des, ROUND(COALESCE(((balance_post_des - balance_prev_des) / balance_prev_des) * 100, balance_post_des), 2) AS porcentaje_incremento
FROM balances;


# 15.  Suponiendo que si no se dispone de información del balance anterior y posterior de un cliente (ya sea emisor o receptor de la operación) 
# no es cliente de Pontia Bank S.L., ¿cuánto dinero en total ha recibido Pontia Bank S.L. (desde destinatarios externos) y
# cuánto ha emitido (a destinatarios externos)? ¿Cuál es la cuantía media y total de las operaciones realizadas entre dos clientes de Pontia Bank S.L.?
# a) Dinero recibido por Pontia Bank S.L
SELECT sum(t.monto) as total_dinero_recibido
FROM transaccion t
INNER JOIN balances b
ON t.t_id=b.t_id
WHERE (b.balance_prev_or=0.00 AND b.balance_post_or=0.00);

# b) Dinero emitido por Pontia Bank S.L
SELECT sum(t.monto) as total_dinero_emitido
FROM transaccion t
INNER JOIN balances b
ON t.t_id=b.t_id
WHERE (b.balance_prev_des=0.00 AND b.balance_post_des=0.00);

# c) Cuantía media y total de las operaciones realizadas entre dos clientes de Pontia Bank S.L.
SELECT sum(t.monto) as total_operaciones, round(avg(t.monto), 2) as media_operaciones
FROM transaccion t
INNER JOIN balances b
ON t.t_id=b.t_id
WHERE (b.balance_prev_or != 0.00 OR  b.balance_post_or != 0.00) AND (b.balance_prev_des != 0.00 OR  b.balance_post_des != 0.00) ;
