-- CASO 1
SELECT
    --NOMBRE
    UPPER(t.nombre || ' ' || t.appaterno || ' ' || t.apmaterno) 
        AS "Nombre Completo Trabajador",

    -- RUT
    SUBSTR(TO_CHAR(t.numrut, '999G999G999'), 2) || '-' || t.dvrut 
        AS "RUT Trabajador",

    -- TIPO TRABAJADOR
    UPPER(NVL(tp.desc_categoria, 'SIN CATEGORIA'))
        AS "Tipo Trabajador",

    -- CIUDAD
    UPPER(NVL(cc.nombre_ciudad, 'SIN CIUDAD'))
        AS "Ciudad Trabajador",

    --SUELDO
    '$' || TO_CHAR(t.sueldo_base, 'FM999G999G999')
        AS "Sueldo Base"

FROM trabajador t
     JOIN tipo_trabajador tp 
         ON t.id_categoria_t = tp.id_categoria
     LEFT JOIN comuna_ciudad cc
         ON t.id_ciudad = cc.id_ciudad

WHERE t.sueldo_base 
      BETWEEN 650000 AND 3000000

ORDER BY 
      cc.nombre_ciudad DESC,
      t.sueldo_base ASC;
      
-- CASO 2
SELECT
    -- RUT 
    SUBSTR(TO_CHAR(t.numrut, '999G999G999'), 2) || '-' || t.dvrut  
        AS "RUT Trabajador",

    -- NOMBRE TRABAJADOR
    INITCAP(t.nombre) || ' ' || UPPER(t.appaterno)
        AS "Nombre Trabajador",

    -- TOTAL TICKET
    COUNT(tc.nro_ticket) AS "Total Tickets",

    -- TOTAL VENDIDO
    '$' || TO_CHAR(SUM(tc.monto_ticket), 'FM999G999G999')
        AS "Total Vendido",

    -- COMISION
    '$' || TO_CHAR(SUM(NVL(ct.valor_comision,0)), 'FM999G999G999')
        AS "Comisión Total",

    -- TIPO TRABAJADOR
    UPPER(tp.desc_categoria) AS "Tipo Trabajador",

    -- CIUDAD
    UPPER(NVL(cc.nombre_ciudad, 'SIN CIUDAD')) AS "Ciudad Trabajador"

FROM trabajador t
    JOIN tipo_trabajador tp 
        ON t.id_categoria_t = tp.id_categoria
    LEFT JOIN comuna_ciudad cc 
        ON t.id_ciudad = cc.id_ciudad
    JOIN tickets_concierto tc 
        ON t.numrut = tc.numrut_t
    LEFT JOIN comisiones_ticket ct
        ON tc.nro_ticket = ct.nro_ticket

WHERE UPPER(tp.desc_categoria) = 'CAJERO'

GROUP BY
    t.numrut, t.dvrut, t.nombre, t.appaterno,
    tp.desc_categoria, cc.nombre_ciudad

HAVING 
    SUM(tc.monto_ticket) > 50000  

ORDER BY
    SUM(tc.monto_ticket) DESC;  
    
-- CASO 3
SELECT
    -- RUT
    SUBSTR(TO_CHAR(t.numrut, '999G999G999'), 2) || '-' || t.dvrut  
        AS "RUT Trabajador",

    -- NOMBRE TRABAJADOR
    INITCAP(t.nombre) || ' ' || INITCAP(t.appaterno)
        AS "Trabajador Nombre",

    -- AÑO DE INGRESO
    TO_CHAR(t.fecing, 'YYYY') AS "Año Ingreso",

    -- AÑOS DE ANTIGUEDAD
    FLOOR(MONTHS_BETWEEN(SYSDATE, t.fecing) / 12)
        AS "Años Antigüedad",

    -- NUM CARGAS FAMILIARES
    COUNT(af.numrut_carga) AS "Num. Cargas Familiares",

    -- ISAPRE O FONASA
    INITCAP(i.nombre_isapre) AS "Nombre Isapre",

    -- SUELDO BASE
    '$' || TO_CHAR(t.sueldo_base, 'FM999G999G999')
        AS "Sueldo Base",

    -- BONO FONASA
    '$' || TO_CHAR(
            CASE 
                WHEN UPPER(i.nombre_isapre) = 'FONASA'
                THEN t.sueldo_base * 0.01
                ELSE 0
            END,
            'FM999G999G999'
        ) AS "Bono Fonasa",

    -- BONO ANTIGUEDAD
    '$' || TO_CHAR(
            CASE
                WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, t.fecing)/12) <= 10
                    THEN t.sueldo_base * 0.10
                ELSE
                    t.sueldo_base * 0.15
            END,
            'FM999G999G999'
        ) AS "Bono Antigüedad",

    -- AFP
    INITCAP(a.nombre_afp) AS "Nombre AFP",

    -- ESTADO CIVIL
    INITCAP(ec.desc_estcivil) AS "Estado Civil"

FROM trabajador t
    LEFT JOIN asignacion_familiar af
        ON t.numrut = af.numrut_t
    JOIN isapre i
        ON t.cod_isapre = i.cod_isapre
    JOIN afp a
        ON t.cod_afp = a.cod_afp
    JOIN est_civil est
        ON t.numrut = est.numrut_t
    JOIN estado_civil ec
        ON est.id_estcivil_est = ec.id_estcivil

WHERE 
    -- ESTADO CIVIL
    (est.fecter_estcivil IS NULL 
     OR est.fecter_estcivil > TRUNC(SYSDATE))

GROUP BY
    t.numrut, t.dvrut,
    t.nombre, t.appaterno,
    t.fecing, t.sueldo_base,
    i.nombre_isapre,
    a.nombre_afp,
    ec.desc_estcivil

ORDER BY t.numrut ASC;
