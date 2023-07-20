USE BANCO;

# TABLA COMPLETA
SELECT t.t_id, tipo, tiempo, monto, cl_origen, cl_destino, balance_prev_or, balance_post_or, balance_prev_or, balance_post_or, es_fraude, mensaje_alarma
FROM transaccion t
INNER JOIN balances b
ON t.t_id=b.t_id
INNER JOIN clientes c
ON b.t_id = c.t_id
INNER JOIN fraude f
ON c.t_id = f.t_id;


# 1. Calcular la media diaria del monto de las transacciones.
select round(avg(monto),2) as media_monto, date(tiempo) as fecha 
from banco.transaccion where month(tiempo)=9 
group by date(tiempo);
select round(avg(monto),2) as media_monto, date(tiempo) as fecha 
from banco.transaccion where month(tiempo)=10 
group by date(tiempo);

# 2. Calcular la cuantía total de las transacciones.
select sum(monto) as monto_total
from banco.transaccion;
# 1144392944759.77€

# 3. ¿Qué días del mes se han producido más transacciones y cuántas?
select count(t_id) as t_id_total, day(tiempo) as día
from transaccion
where month(tiempo)=9
group by day(tiempo)
order by t_id_total desc limit 1;
# En septiembre, el día 2 con 467.735 transacciones totales

select count(t_id) as t_id_total, day(tiempo) as día
from transaccion
where month(tiempo)=10
group by day(tiempo)
order by t_id_total desc limit 1;
# # En octubre, el día 1 con 4.476 transacciones totales

# 4. ¿A qué horas del día se producen más transacciones y cuántas?
select count(t_id) as total_transacciones_hora, hour(tiempo) as hora
from transaccion
where month(tiempo) = 9
group by hour(tiempo)
order by total_transacciones_hora desc;
# A las 1:00 am con 645.925 transacciones y a las 00:00 con 579.818 transacciones

# 5. ¿Cuáles son los 5 clientes que han transferido más dinero y cuánto?
select c.cl_origen, sum(t.monto) as monto_total
from transaccion t
inner join clientes c
on t.t_id= c.t_id
group by c.cl_origen
order by monto_total desc
limit 5;
# Por orden descendiente, los clientes 'C1715283297', 'C2127282686', 'C2044643633', 'C1425667947' y 'C1584456031' 
# con un total de 92445516.64€, 73823490.36€, 71172480.42€, 69886731.30€ y 69337316.27€ respectivamnete.


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
# Han sido 'C439737079'(357440831.44€), 'C707403537'(299374418.42€), 'C167875008'(274736432.80€), 'C20253152'(270116188.69€), 'C172409641'(255310174.25€), 
# 'C268913927'(253484588.10€), 'C936857833'(227780012.02€), 'C65111466'(227443845.85€), 'C744189981'(225173861.73€) y 'C1406193485'(224778961.83€)

# 8.  ¿Cuáles son los 3 clientes con mejor balance a lo largo del mes (aquellos que al restarle al dinero recibido al
#  dinero enviado se quedan con un mejor resultado) y cuál ha sido su balance?
SELECT (t.balance_total1 + t.balance_total2) as balance_total, coalesce(cl_origen, cl_destino)  
FROM (SELECT * FROM balance_origen bo1
LEFT JOIN balance_destino bd1
ON bo1.cl_origen = bd1.cl_destino
UNION
SELECT * FROM balance_origen bo2
RIGHT JOIN balance_destino bd2
ON bo2.cl_origen = bd2.cl_destino) t

order by balance_total desc
limit 3;

SELECT * FROM balance_origen;
SELECT * FROM balance_destino;

CREATE VIEW balance_origen as select c.cl_origen, sum(balance_post_or-balance_prev_or) as balance_total1
from balances b
inner join transaccion t
on b.t_id= t.t_id
inner join clientes c
on t.t_id=c.t_id
group by c.cl_origen;

CREATE VIEW balance_destino as select c.cl_destino, sum(balance_post_des-balance_prev_des) as balance_total2
from balances b
inner join transaccion t
on b.t_id= t.t_id
inner join clientes c
on t.t_id=c.t_id
group by c.cl_destino;
 
# 9.  ¿Cuáles son los 3 clientes con peor balance a lo largo de todo el mes y cuál ha sido?
SELECT (t.balance_total1 + t.balance_total2) as balance_total, coalesce(cl_origen, cl_destino)  
FROM (SELECT * FROM balance_origen bo1
LEFT JOIN balance_destino bd1
ON bo1.cl_origen = bd1.cl_destino
UNION
SELECT * FROM balance_origen bo2
RIGHT JOIN balance_destino bd2
ON bo2.cl_origen = bd2.cl_destino) t

order by balance_total
limit 3;

SELECT * FROM balance_origen;
SELECT * FROM balance_destino;

CREATE VIEW balance_origen as select c.cl_origen, sum(balance_post_or-balance_prev_or) as balance_total1
from balances b
inner join transaccion t
on b.t_id= t.t_id
inner join clientes c
on t.t_id=c.t_id
group by c.cl_origen;

CREATE VIEW balance_destino as select c.cl_destino, sum(balance_post_des-balance_prev_des) as balance_total2
from balances b
inner join transaccion t
on b.t_id= t.t_id
inner join clientes c
on t.t_id=c.t_id
group by c.cl_destino;

# 10. ¿Cuántas transacciones fraudulentas se han producido?
SELECT COUNT(es_fraude) AS ‘total_fraude’
FROM fraude
WHERE es_fraude=1;
# 8209 en total

# 11. Diferenciando entre si las transacciones han producido una alarma de transacción fraudulenta en los sistemas, ¿cuántas han sido realmente fraudulentas y cuántas no?
# Transacciones que han hecho saltar mensaje alarma y SÍ han sido fraudulentas
SELECT COUNT(es_fraude) AS ‘true_fraude’
FROM fraude
WHERE es_fraude= 1 AND mensaje_alarma ='Detectado_fraude';
# 16 en total

# Transacciones que han hecho saltar mensaje alarma y NO han sido fraudulentas
SELECT COUNT(es_fraude) AS ‘fake_fraude’
FROM fraude
WHERE es_fraude= 0 AND mensaje_alarma ='Detectado_fraude';
# Ninguna

# Transacciones fraudulentas que NO han hecho saltar mensaje alarma
SELECT COUNT(es_fraude) AS ‘fraude_no_detectado’
FROM fraude
WHERE es_fraude= 1 AND mensaje_alarma ='No';
# 8193

# 12. ¿Cuántas transacciones se producen por cada tipo de operación?
select tipo, count(t_id) as cantidad_transacciones
from transaccion
group by tipo;
# 2151495 tipo 'Payment', 532909 'transfer', 2237500 'cash_out', 41432 'debit',  1399284 'cash_in'

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
# 446.850.207.272,78€

# b) Dinero emitido por Pontia Bank S.L
SELECT sum(t.monto) as total_dinero_emitido
FROM transaccion t
INNER JOIN balances b
ON t.t_id=b.t_id
WHERE (b.balance_prev_des=0.00 AND b.balance_post_des=0.00);
# 62.714.148.168,05€

# c) Cuantía media y total de las operaciones realizadas entre dos clientes de Pontia Bank S.L.
SELECT sum(t.monto) as total_operaciones, round(avg(t.monto), 2) as media_operaciones
FROM transaccion t
INNER JOIN balances b
ON t.t_id=b.t_id
WHERE (b.balance_prev_or != 0.00 OR  b.balance_post_or != 0.00) AND (b.balance_prev_des != 0.00 OR  b.balance_post_des != 0.00) ;
# Cuantía media: 236.246,02€ , cuantía total: 645.091.020.121,06€
