
-- SCRIPT ASUMIENDO QUE LAS DB ESTAN CREADAS Y POBLADAS

-- CONSULTA CASO 1
-- NOTA: INTRODUCIR 190000 EN RENTA MINIMA Y 1200000 EN MAXIMA PARA QUE SALGA LA CONSULTA SOLICITADA
SET LINESIZE 200
SET PAGESIZE 50
COLUMN "RUT Cliente"            FORMAT A15
COLUMN "Nombre Completo Cliente" FORMAT A30
COLUMN "Dirección Cliente"       FORMAT A35
COLUMN "Renta Cliente"           FORMAT A15
COLUMN "Celular Cliente"         FORMAT A15
COLUMN "Tramo Renta Cliente"     FORMAT A12

ACCEPT min_renta PROMPT 'Ingrese renta mínima: '
ACCEPT max_renta PROMPT 'Ingrese renta máxima: '

SELECT 
    SUBSTR(TO_CHAR(LPAD(c.numrut_cli, 9, '0'), 'FM999G999G999'), 1, LENGTH(TO_CHAR(c.numrut_cli)))
    || '-' || c.dvrut_cli AS "RUT Cliente",

    c.nombre_cli || ' ' || c.appaterno_cli || ' ' || c.apmaterno_cli AS "Nombre Completo Cliente",

    c.direccion_cli AS "Dirección Cliente",

    TO_CHAR(c.renta_cli, '$999G999G990') AS "Renta Cliente",

    c.celular_cli AS "Celular Cliente",

    CASE 
        WHEN c.renta_cli > 500000 THEN 'TRAMO 1'
        WHEN c.renta_cli BETWEEN 400000 AND 500000 THEN 'TRAMO 2'
        WHEN c.renta_cli BETWEEN 200000 AND 399999 THEN 'TRAMO 3'
        ELSE 'TRAMO 4'
    END AS "Tramo Renta Cliente"

FROM cliente c
WHERE c.celular_cli IS NOT NULL
  AND c.renta_cli BETWEEN TO_NUMBER(REPLACE('&min_renta', '.', '')) 
                      AND TO_NUMBER(REPLACE('&max_renta', '.', ''))
ORDER BY c.renta_cli DESC;

-- CONSULTA CASO 2
-- NOTA: PARA QUE SALGA LA CONSULTA EXACTA INTRODUCIR "1100000" EN LO SOLICITADO
SET LINESIZE 180
SET PAGESIZE 50
COLUMN "CODIGO_CATEGORIA"       FORMAT 999
COLUMN "DESCRIPCION_CATEGORIA"  FORMAT A25
COLUMN "CANTIDAD_EMPLEADOS"     FORMAT 999
COLUMN "SUCURSAL"               FORMAT A25
COLUMN "SUELDO_PROMEDIO"        FORMAT A15

ACCEPT SUELDO_PROMEDIO_MINIMO PROMPT 'Ingrese sueldo promedio mínimo a considerar: '

SELECT 
    e.id_categoria_emp AS "CODIGO_CATEGORIA",
    INITCAP(ce.desc_categoria_emp) AS "DESCRIPCION_CATEGORIA",
    COUNT(e.numrut_emp) AS "CANTIDAD_EMPLEADOS",
    'Sucursal ' || INITCAP(s.desc_sucursal) AS "SUCURSAL",
    TO_CHAR(ROUND(AVG(NVL(e.sueldo_emp,0))), '$999G999G999') AS "SUELDO_PROMEDIO"

FROM empleado e
JOIN categoria_empleado ce ON ce.id_categoria_emp = e.id_categoria_emp
JOIN sucursal s ON s.id_sucursal = e.id_sucursal

GROUP BY e.id_categoria_emp, ce.desc_categoria_emp, s.desc_sucursal

HAVING AVG(NVL(e.sueldo_emp,0)) >= TO_NUMBER(REPLACE('&SUELDO_PROMEDIO_MINIMO','.',''))

ORDER BY AVG(e.sueldo_emp) DESC;

-- CONSULTA CASO 3
SET LINESIZE 200
SET PAGESIZE 50

COLUMN "CODIGO_TIPO"         FORMAT A5
COLUMN "DESCRIPCION_TIPO"    FORMAT A25
COLUMN "TOTAL_PROPIEDADES"   FORMAT 999
COLUMN "PROMEDIO_ARRIENDO"   FORMAT A15
COLUMN "PROMEDIO_SUPERFICIE" FORMAT A10
COLUMN "VALOR_ARRIENDO_M2"   FORMAT A15
COLUMN "CLASIFICACION"       FORMAT A12

SELECT
    p.id_tipo_propiedad AS "CODIGO_TIPO",

    CASE p.id_tipo_propiedad
        WHEN 'A' THEN 'CASA'
        WHEN 'B' THEN 'DEPARTAMENTO'
        WHEN 'C' THEN 'LOCAL'
        WHEN 'D' THEN 'PARCELA SIN CASA'
        WHEN 'E' THEN 'PARCELA CON CASA'
    END AS "DESCRIPCION_TIPO",

    COUNT(*) AS "TOTAL_PROPIEDADES",

    TO_CHAR(ROUND(AVG(NVL(p.valor_arriendo,0))), '$999G999G999') AS "PROMEDIO_ARRIENDO",

    TO_CHAR(
        ROUND(AVG(NVL(p.superficie,0)), 2),
        '999G990D00',
        'NLS_NUMERIC_CHARACTERS='',.'''
    ) AS "PROMEDIO_SUPERFICIE",

    TO_CHAR(
        ROUND( AVG(NVL(p.valor_arriendo,0)) / NULLIF(AVG(NVL(p.superficie,0)),0), 0 ),
        '$999G999G999'
    ) AS "VALOR_ARRIENDO_M2",

    CASE 
        WHEN (AVG(NVL(p.valor_arriendo,0)) / NULLIF(AVG(NVL(p.superficie,0)),0)) < 5000
            THEN 'Económico'
        WHEN (AVG(NVL(p.valor_arriendo,0)) / NULLIF(AVG(NVL(p.superficie,0)),0)) BETWEEN 5000 AND 10000
            THEN 'Medio'
        ELSE 'Alto'
    END AS "CLASIFICACION"

FROM propiedad p

GROUP BY
    p.id_tipo_propiedad,
    CASE p.id_tipo_propiedad
        WHEN 'A' THEN 'CASA'
        WHEN 'B' THEN 'DEPARTAMENTO'
        WHEN 'C' THEN 'LOCAL'
        WHEN 'D' THEN 'PARCELA SIN CASA'
        WHEN 'E' THEN 'PARCELA CON CASA'
    END

HAVING
    (AVG(NVL(p.valor_arriendo,0)) / NULLIF(AVG(NVL(p.superficie,0)),0)) > 1000

ORDER BY
    (AVG(NVL(p.valor_arriendo,0)) / NULLIF(AVG(NVL(p.superficie,0)),0)) DESC;