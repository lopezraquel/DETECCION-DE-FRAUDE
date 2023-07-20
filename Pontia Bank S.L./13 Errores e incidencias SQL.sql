# ERRORES E INCIDENCIAS

# Unión de tabla balances, transaccion y clientes
SELECT *
FROM balances b
INNER JOIN transaccion t
ON b.t_id=t.t_id
INNER JOIN clientes c
ON t.t_id=c.t_id;

# El límite de la retirada de efectivo es de 2000€ al día
SELECT SUM(t.monto) as total_retirada_efectivo , c.cl_origen, day(tiempo) as día
FROM transaccion t
INNER JOIN clientes c
ON t.t_id=c.t_id
WHERE tipo = 'CASH_OUT'
GROUP BY c.cl_origen, day(tiempo)
HAVING SUM(t.monto) > 2000;
# Vemos que hay varios clientes para los que se excede el límite, por ejemplo 'C1000000639' con 244.486,46€ o 'C1000004053' con 211.189,64€


# El límite de pago con tarjeta de débito al mes es de 5000€
# Para visualizar la situación
SELECT t.t_id, c.cl_origen, c.cl_destino, t.monto, t.tiempo, b.balance_prev_or, b.balance_post_or, b.balance_prev_des, b.balance_post_des
FROM transaccion t
INNER JOIN clientes c
ON t.t_id=c.t_id
INNER JOIN balances b
ON b.t_id=c.t_id
WHERE tipo = 'DEBIT';

# Lo calculamos
SELECT SUM(t.monto) AS total_pago_tarjeta, c.cl_origen, month(tiempo) as mes
FROM transaccion t
INNER JOIN clientes c
ON t.t_id=c.t_id
WHERE tipo = 'DEBIT'
GROUP BY c.cl_origen, month(tiempo)
HAVING SUM(t.monto) > 5000;
# Vemos que hay varios clientes para los que se excede el límite, por ejemplo 'C712410124' con 5337.77€, 'C1900366749' con 9644.94€, 'C1566511282' con 9302.79€,... 

#  No se pueden producir tres transferencias en una misma hora
# Para visualizar la situación
SELECT t.t_id, c.cl_origen, c.cl_destino, t.monto, t.tiempo, b.balance_prev_or, b.balance_post_or, b.balance_prev_des, b.balance_post_des, t.tipo
FROM transaccion t
INNER JOIN clientes c
ON t.t_id=c.t_id
INNER JOIN balances b
ON b.t_id=c.t_id
WHERE tipo = 'TRANSFER';

# Lo calculamos
SELECT COUNT(*) as num_transferencias, c.cl_origen, t.tiempo
FROM transaccion t
INNER JOIN clientes c
ON t.t_id=c.t_id
WHERE tipo = 'TRANSFER'
GROUP BY c.cl_origen, t.tiempo
HAVING num_transferencias > 2;
# Sale que no hay ningún cliente que lo cumpla

# No se pueden producir varias transferencias que juntas sumen más de 3000€ en una misma hora
SELECT SUM(t.monto) AS total_transferencias, c.cl_origen, tiempo
FROM transaccion t
INNER JOIN clientes c
ON t.t_id=c.t_id
WHERE tipo = 'TRANSFER'
GROUP BY c.cl_origen, tiempo
HAVING SUM(t.monto) > 3000;
# Tampoco se cumple


# Comprobar si los incrementos de los balances coinciden con las cuantías de las transacciones

# 1. Filtramos columnas en que ambos valores coinciden
SELECT t.t_id, b.balance_prev_or, b.balance_post_or, ABS((b.balance_prev_or - b.balance_post_or)) as incremento_balance_or,  monto
FROM transaccion t
INNER JOIN balances b
ON t.t_id=b.t_id
WHERE ABS((b.balance_prev_or - b.balance_post_or)) = t.monto;

# 2. Filtramos columnas en que ambos valores NO coinciden
SELECT t.t_id, b.balance_prev_or, b.balance_post_or, ABS((b.balance_prev_or - b.balance_post_or)) as incremento_balance_or,  t.monto
FROM transaccion t
INNER JOIN balances b
ON t.t_id=b.t_id
WHERE ABS((b.balance_prev_or - b.balance_post_or)) != t.monto AND (b.balance_prev_or != 0 and b.balance_post_or != 0);
# Vemos que en la mayoría coinciden, pero aquí se muestran algunas como distinto por no coincidir las décimas en la parte decimal al aproximar

# 3. Idem para cliente destino
SELECT t.t_id, b.balance_prev_des, b.balance_post_des, ABS((b.balance_post_des - b.balance_prev_des)) as incremento_balance_des,  t.monto
FROM transaccion t
INNER JOIN balances b
ON t.t_id=b.t_id
WHERE ABS((b.balance_post_des - b.balance_prev_des)) = t.monto;

SELECT t.t_id, b.balance_prev_des, b.balance_post_des, ABS((b.balance_post_des - b.balance_prev_des)) as incremento_balance_des,  t.monto
FROM transaccion t
INNER JOIN balances b
ON t.t_id=b.t_id
WHERE ABS((b.balance_post_des - b.balance_prev_des)) != t.monto AND (b.balance_post_des != 0 and b.balance_prev_des != 0);
# Aquí vemos más errores, en la gran mayoría de transacciones no coinciden los incrementos con los montos

# Búsqueda de valores nulos en los registros
SELECT t.t_id, tipo, tiempo, monto, cl_origen, cl_destino, balance_prev_or, balance_post_or, balance_prev_or, balance_post_or, es_fraude, mensaje_alarma
FROM transaccion t
INNER JOIN balances b
ON t.t_id=b.t_id
INNER JOIN clientes c
ON b.t_id = c.t_id
INNER JOIN fraude f
ON c.t_id = f.t_id
WHERE (t.t_id or tipo or tiempo or monto or cl_origen or cl_destino or balance_prev_or or balance_post_or or balance_prev_or or balance_post_or or es_fraude or mensaje_alarma) IS NULL;
# No hay

# Búsqueda de valores y registro duplicados
# Vemos el dataset completo
SELECT t.t_id, tipo, tiempo, monto, cl_origen, cl_destino, balance_prev_or, balance_post_or, balance_prev_or, balance_post_or, es_fraude, mensaje_alarma
FROM transaccion t
INNER JOIN balances b
ON t.t_id=b.t_id
INNER JOIN clientes c
ON b.t_id = c.t_id
INNER JOIN fraude f
ON c.t_id = f.t_id;

# ¿Aparece alguna transacción repetida?
SELECT COUNT(DISTINCT t_id) as valores_unicos FROM transaccion; #aquí no
SELECT COUNT(DISTINCT t_id) as valores_unicos FROM balances; #aquí no
SELECT COUNT(DISTINCT t_id) as valores_unicos FROM clientes; #aquí no
SELECT COUNT(DISTINCT t_id) as valores_unicos FROM fraude; #aquí no

# ¿Hay algún tipo de transferencia que no produzca fraude?
SELECT sum(es_fraude) as total_fraude, tipo
FROM transaccion t
INNER JOIN fraude f
ON t.t_id=f.t_id
GROUP BY tipo;
# ¡Sí! Los tipos Payment, Debit y Cash_in no producen fraude. En cambio, de tipo Transfer se producen 4095 fraudes y de tipo Cash_out 4114.

# ¿Influye el día o la hora a la hora de hacer fraude?
SELECT sum(es_fraude) as total_fraude, day(tiempo) as día
FROM transaccion t
INNER JOIN fraude f
ON t.t_id=f.t_id
GROUP BY day(tiempo)
ORDER BY total_fraude desc;
# El día 1 es con diferencia cuando más fraude se produce, seguido del día 2 pero esto es porque 
# se tiene también en cuenta los registros del 1 y 2 de octubre. Si se desprecian, el día parece no influir

SELECT sum(es_fraude) as total_fraude, hour(tiempo) as hora
FROM transaccion t
INNER JOIN fraude f
ON t.t_id=f.t_id
GROUP BY hour(tiempo)
ORDER BY total_fraude desc;
# A las 6:00 y las 10:00 se aprecia una caída en el nº de fraude.

#¿Hay algún día en que nunca se produzca fraude?
SELECT sum(es_fraude) as total_fraude, day(tiempo) as día
FROM transaccion t
INNER JOIN fraude f
ON t.t_id=f.t_id
GROUP BY day(tiempo)
HAVING sum(es_fraude) = 0;
# No, todos los días hay algún fraude

# ¿Y horas en que no haya fraude?
SELECT sum(es_fraude) as total_fraude, hour(tiempo) as hora
FROM transaccion t
INNER JOIN fraude f
ON t.t_id=f.t_id
GROUP BY hour(tiempo)
HAVING sum(es_fraude) = 0;
# Tampoco

# ¿Hay algún cliente con tendencia a cometer fraude?
SELECT sum(es_fraude) as total_fraude, cl_origen
FROM clientes c
INNER JOIN fraude f
ON c.t_id=f.t_id
GROUP BY cl_origen
ORDER BY total_fraude desc;
# Parece que no, los clientes como mucho cometen fraude una vez


SELECT max(monto), min(monto) 
FROM transaccion t;