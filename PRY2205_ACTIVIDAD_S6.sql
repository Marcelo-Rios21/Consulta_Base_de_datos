--CASO 1

SELECT 
       id_profesional                         AS ID,
       nombre_prof                             AS PROFESIONAL,
       SUM(nro_banca)                          AS NRO_ASESORIA_BANCA,
       TO_CHAR(SUM(monto_banca), '$999G999G999')  AS MONTO_TOTAL_BANCA,
       SUM(nro_retail)                         AS NRO_ASESORIA_RETAIL,
       TO_CHAR(SUM(monto_retail), '$999G999G999') AS MONTO_TOTAL_RETAIL,
       (SUM(nro_banca) + SUM(nro_retail))      AS TOTAL_ASESORIAS,
       TO_CHAR(SUM(monto_banca + monto_retail), '$999G999G999') 
                                                AS TOTAL_HONORARIOS
FROM (

         --DATOS DE BANCA
      SELECT 
             p.id_profesional,
             p.appaterno || ' ' || p.apmaterno || ' ' || p.nombre AS nombre_prof,
             COUNT(a.honorario) AS nro_banca,
             SUM(a.honorario)  AS monto_banca,
             0 AS nro_retail,
             0 AS monto_retail
      FROM profesional p
      JOIN asesoria a      ON p.id_profesional = a.id_profesional
      JOIN empresa  e      ON a.cod_empresa   = e.cod_empresa
      WHERE e.cod_sector = 3                
      GROUP BY p.id_profesional, p.appaterno, p.apmaterno, p.nombre

      UNION ALL

         --DATOS DE RETAIL
      SELECT 
             p.id_profesional,
             p.appaterno || ' ' || p.apmaterno || ' ' || p.nombre AS nombre_prof,
             0 AS nro_banca,
             0 AS monto_banca,
             COUNT(a.honorario) AS nro_retail,
             SUM(a.honorario) AS monto_retail
      FROM profesional p
      JOIN asesoria a      ON p.id_profesional = a.id_profesional
      JOIN empresa  e      ON a.cod_empresa   = e.cod_empresa
      WHERE e.cod_sector = 4                
      GROUP BY p.id_profesional, p.appaterno, p.apmaterno, p.nombre
)
GROUP BY id_profesional, nombre_prof
HAVING SUM(nro_banca)  > 0  
   AND SUM(nro_retail) > 0  
ORDER BY id_profesional ASC;

--CASO 2
--EJECUTAR SOLO UNA VEZ
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE REPORTE_MES';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

CREATE TABLE REPORTE_MES (
    id_prof                NUMBER(10),
    nombre_completo        VARCHAR2(60),
    nombre_profesion       VARCHAR2(40),
    nom_comuna             VARCHAR2(40),
    nro_asesorias          NUMBER(5),
    monto_total_honorarios NUMBER(12),
    promedio_honorario     NUMBER(12),
    honorario_minimo       NUMBER(12),
    honorario_maximo       NUMBER(12)
);

--CONSULTA
INSERT INTO REPORTE_MES
SELECT
    p.id_profesional                                        AS ID_PROF,
    p.appaterno || ' ' || p.apmaterno || ' ' || p.nombre    AS NOMBRE_COMPLETO,
    pr.nombre_profesion                                     AS NOMBRE_PROFESION,
    c.nom_comuna                                            AS NOM_COMUNA,

    COUNT(*)                                                AS NRO_ASESORIAS,
    ROUND(SUM(a.honorario), 0)                              AS MONTO_TOTAL_HONORARIOS,
    ROUND(AVG(a.honorario), 0)                              AS PROMEDIO_HONORARIO,
    ROUND(MIN(a.honorario), 0)                              AS HONORARIO_MINIMO,
    ROUND(MAX(a.honorario), 0)                              AS HONORARIO_MAXIMO

FROM profesional p
JOIN asesoria a    ON p.id_profesional = a.id_profesional
JOIN profesion pr  ON p.cod_profesion = pr.cod_profesion
JOIN comuna c      ON p.cod_comuna = c.cod_comuna

WHERE a.fin_asesoria BETWEEN
      ADD_MONTHS(TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR'), 3)   
  AND LAST_DAY(ADD_MONTHS(TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR'), 3))  

GROUP BY
    p.id_profesional,
    p.appaterno, p.apmaterno, p.nombre,
    pr.nombre_profesion,
    c.nom_comuna

ORDER BY p.id_profesional ASC;

COMMIT;

--CASO 3
SELECT
    ROUND(SUM(a.honorario), 0)     AS HONORARIO,
    p.id_profesional               AS ID_PROFESIONAL,
    p.numrun_prof                  AS NUMRUN_PROF,
    p.sueldo                       AS SUELDO
FROM profesional p
JOIN asesoria a ON p.id_profesional = a.id_profesional
WHERE a.fin_asesoria BETWEEN
      ADD_MONTHS(TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR'), 2)
  AND LAST_DAY(ADD_MONTHS(TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR'), 2))
GROUP BY 
    p.id_profesional,
    p.numrun_prof,
    p.sueldo
ORDER BY p.id_profesional;

 --ACTUALIZACION
UPDATE (
    SELECT 
        p.sueldo AS sueldo_actual,
        ac.total_honorarios AS total_honos
    FROM profesional p
    JOIN (
        SELECT 
            id_profesional,
            SUM(honorario) AS total_honorarios
        FROM asesoria
        WHERE fin_asesoria BETWEEN
              ADD_MONTHS(TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR'), 2)
          AND LAST_DAY(ADD_MONTHS(TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR'), 2))
        GROUP BY id_profesional
    ) ac
        ON ac.id_profesional = p.id_profesional
) t
SET t.sueldo_actual =
    t.sueldo_actual *
        CASE 
            WHEN t.total_honos < 1000000 THEN 1.10
            ELSE 1.15
        END;

COMMIT;

 --REPORTE POST ACTUALIZACION
SELECT
    ROUND(SUM(a.honorario), 0)     AS HONORARIO,
    p.id_profesional               AS ID_PROFESIONAL,
    p.numrun_prof                  AS NUMRUN_PROF,
    p.sueldo                       AS SUELDO_ACTUALIZADO
FROM profesional p
JOIN asesoria a ON p.id_profesional = a.id_profesional
WHERE a.fin_asesoria BETWEEN
      ADD_MONTHS(TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR'), 2)
  AND LAST_DAY(ADD_MONTHS(TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR'), 2))
GROUP BY 
    p.id_profesional,
    p.numrun_prof,
    p.sueldo
ORDER BY p.id_profesional;
