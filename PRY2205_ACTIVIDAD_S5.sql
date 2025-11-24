-- CASO 1

SELECT
    TRIM(TO_CHAR(c.numrun, '99G999G999')) || '-' || UPPER(c.dvrun) AS "RUT Cliente",
    INITCAP(c.pnombre || ' ' || c.appaterno) AS "Nombre Cliente",
    UPPER(po.nombre_prof_ofic) AS "Profesión Cliente",
    TO_CHAR(c.fecha_inscripcion, 'DD-MM-YYYY') AS "Fecha de Inscripción",
    c.direccion AS "Dirección Cliente"
FROM cliente c
JOIN profesion_oficio po
        ON c.cod_prof_ofic = po.cod_prof_ofic
WHERE 
      UPPER(po.nombre_prof_ofic) IN ('CONTADOR','VENDEDOR')
-- SE INTRODUCE CODIGO EXACTO POR DUPLICIDAD
  AND c.cod_tipo_cliente = 10
  AND EXTRACT(YEAR FROM c.fecha_inscripcion) >
      (SELECT ROUND(AVG(EXTRACT(YEAR FROM fecha_inscripcion))) FROM cliente)
  AND EXTRACT(YEAR FROM c.fecha_inscripcion) BETWEEN 2010 AND 2013
ORDER BY c.numrun ASC;

-- CASO 2

CREATE TABLE CLIENTES_CUPOS_COMPRA AS
-- LUEGO DE CREAR TABLA, EJECUTAR SOLO EL SELECT
SELECT
       c.numrun || '-' || c.dvrun                               AS RUT_CLIENTE,
       TRUNC( MONTHS_BETWEEN(SYSDATE, c.fecha_nacimiento)/12 )  AS EDAD,
       TO_CHAR(tc.cupo_disp_compra, '$999G999G999')             AS CUPO_DISPONIBLE_COMPRA,
       UPPER(tccli.nombre_tipo_cliente)                         AS TIPO_CLIENTE
FROM cliente c
JOIN tarjeta_cliente tc
     ON c.numrun = tc.numrun
JOIN tipo_cliente tccli
     ON c.cod_tipo_cliente = tccli.cod_tipo_cliente
WHERE tc.cupo_disp_compra >= (
        SELECT MAX(tc2.cupo_disp_compra)
        FROM tarjeta_cliente tc2
        WHERE EXTRACT(YEAR FROM tc2.fecha_solic_tarjeta) =
              EXTRACT(YEAR FROM ADD_MONTHS(SYSDATE, -12))
)
ORDER BY TRUNC( MONTHS_BETWEEN(SYSDATE, c.fecha_nacimiento)/12 );

