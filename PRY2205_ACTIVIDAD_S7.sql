--CASO 1
--SINONIMOS PRIV
CREATE SYNONYM syn_trabajador FOR trabajador;
CREATE SYNONYM syn_bono_ant FOR bono_antiguedad;
CREATE SYNONYM syn_tickets FOR tickets_concierto;

SELECT
    100 + (ROW_NUMBER() OVER (
            ORDER BY q.monto_ticket DESC, q.nombre_trabajador ASC
          ) - 1) * 10                                                          AS num,
    q.rut                                                                        AS rut,
    q.nombre_trabajador                                                          AS nombre_trabajador,
    TO_CHAR(ROUND(q.sueldo_base,0), 'FM$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') AS sueldo_base,
    q.num_ticket                                                                 AS num_ticket,
    q.direccion                                                                  AS direccion,
    q.sistema_salud                                                              AS sistema_salud,
    TO_CHAR(ROUND(q.monto_ticket,0), 'FM$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') AS monto,
    TO_CHAR(ROUND(q.bonif_ticket,0), 'FM$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') AS bonif_x_ticket,
    TO_CHAR(ROUND(q.simul_ticket,0), 'FM$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') AS simulacion_x_ticket,
    TO_CHAR(ROUND(q.simul_antig,0),  'FM$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') AS simulacion_antiguedad
FROM (
    SELECT
        TO_CHAR(t.numrut) || '-' || t.dvrut                                       AS rut,
        INITCAP(t.nombre || ' ' || t.appaterno || ' ' || t.apmaterno)             AS nombre_trabajador,
        t.sueldo_base                                                             AS sueldo_base,
        CASE WHEN tc.nro_ticket IS NULL THEN 'No hay info'
             ELSE TO_CHAR(tc.nro_ticket)
        END                                                                       AS num_ticket,
        t.direccion                                                               AS direccion,
        i.nombre_isapre                                                           AS sistema_salud,
        NVL(tc.monto_ticket, 0)                                                   AS monto_ticket,

        CASE
            WHEN tc.nro_ticket IS NULL THEN 0
            WHEN tc.monto_ticket <= 50000 THEN 0
            WHEN tc.monto_ticket <= 100000 THEN tc.monto_ticket * 0.05
            ELSE tc.monto_ticket * 0.07
        END                                                                       AS bonif_ticket,

        ( t.sueldo_base +
          CASE
              WHEN tc.nro_ticket IS NULL THEN 0
              WHEN tc.monto_ticket <= 50000 THEN 0
              WHEN tc.monto_ticket <= 100000 THEN tc.monto_ticket * 0.05
              ELSE tc.monto_ticket * 0.07
          END
        )                                                                          AS simul_ticket,

        ( t.sueldo_base * (1 + ba.porcentaje) )                                    AS simul_antig

    FROM syn_trabajador t
    JOIN isapre i
      ON i.cod_isapre = t.cod_isapre

    LEFT JOIN syn_tickets tc
      ON tc.numrut_t = t.numrut

    /* NonEquiJoin + MATCH OBLIGATORIO (como en la figura 3) */
    JOIN syn_bono_ant ba
      ON ROUND(MONTHS_BETWEEN(TRUNC(SYSDATE), t.fecing) / 12)
         BETWEEN ba.limite_inferior AND ba.limite_superior

    WHERE i.porc_descto_isapre > 4
      AND FLOOR(MONTHS_BETWEEN(TRUNC(SYSDATE), NVL(t.fecnac, TRUNC(SYSDATE))) / 12) < 50
) q
ORDER BY
    q.monto_ticket DESC,
    q.nombre_trabajador ASC;

--INFORME FINAL 
INSERT INTO detalle_bonificaciones_trabajador (
    num,
    rut,
    nombre_trabajador,
    sueldo_base,
    num_ticket,
    direccion,
    sistema_salud,
    monto,
    bonif_x_ticket,
    simulacion_x_ticket,
    simulacion_antiguedad
)
SELECT
    seq_det_bonif.NEXTVAL                                                       AS num,
    q.rut                                                                        AS rut,
    q.nombre_trabajador                                                          AS nombre_trabajador,
    TO_CHAR(ROUND(q.sueldo_base,0), 'FM$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') AS sueldo_base,
    q.num_ticket                                                                 AS num_ticket,
    q.direccion                                                                  AS direccion,
    q.sistema_salud                                                              AS sistema_salud,
    TO_CHAR(ROUND(q.monto_ticket,0), 'FM$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') AS monto,
    TO_CHAR(ROUND(q.bonif_ticket,0), 'FM$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') AS bonif_x_ticket,
    TO_CHAR(ROUND(q.simul_ticket,0), 'FM$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') AS simulacion_x_ticket,
    TO_CHAR(ROUND(q.simul_antig,0),  'FM$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') AS simulacion_antiguedad
FROM (
    SELECT
        TO_CHAR(t.numrut) || '-' || t.dvrut                                       AS rut,
        INITCAP(t.nombre || ' ' || t.appaterno || ' ' || t.apmaterno)             AS nombre_trabajador,
        t.sueldo_base                                                             AS sueldo_base,
        CASE WHEN tc.nro_ticket IS NULL THEN 'No hay info'
             ELSE TO_CHAR(tc.nro_ticket)
        END                                                                       AS num_ticket,
        t.direccion                                                               AS direccion,
        i.nombre_isapre                                                           AS sistema_salud,
        NVL(tc.monto_ticket, 0)                                                   AS monto_ticket,

        CASE
            WHEN tc.nro_ticket IS NULL THEN 0
            WHEN tc.monto_ticket <= 50000 THEN 0
            WHEN tc.monto_ticket <= 100000 THEN tc.monto_ticket * 0.05
            ELSE tc.monto_ticket * 0.07
        END                                                                       AS bonif_ticket,

        ( t.sueldo_base +
          CASE
              WHEN tc.nro_ticket IS NULL THEN 0
              WHEN tc.monto_ticket <= 50000 THEN 0
              WHEN tc.monto_ticket <= 100000 THEN tc.monto_ticket * 0.05
              ELSE tc.monto_ticket * 0.07
          END
        )                                                                          AS simul_ticket,

        ( t.sueldo_base * (1 + ba.porcentaje) )                                    AS simul_antig

    FROM syn_trabajador t
    JOIN isapre i
      ON i.cod_isapre = t.cod_isapre

    LEFT JOIN syn_tickets tc
      ON tc.numrut_t = t.numrut

    JOIN syn_bono_ant ba
      ON ROUND(MONTHS_BETWEEN(TRUNC(SYSDATE), t.fecing) / 12)
         BETWEEN ba.limite_inferior AND ba.limite_superior

    WHERE i.porc_descto_isapre > 4
      AND FLOOR(MONTHS_BETWEEN(TRUNC(SYSDATE), NVL(t.fecnac, TRUNC(SYSDATE))) / 12) < 50
) q;

COMMIT;

--REPORTE
SELECT *
FROM detalle_bonificaciones_trabajador
ORDER BY TO_NUMBER(REPLACE(REPLACE(monto,'$',''),'.','')) DESC,
         nombre_trabajador ASC;

--CASO 2
--ETAPA 1
--SINONIMOS
CREATE SYNONYM syn_bono_escolar FOR bono_escolar;
CREATE SYNONYM syn_tipo_trab    FOR tipo_trabajador;

CREATE OR REPLACE VIEW v_aumentos_estudios AS
SELECT
    TO_CHAR(t.numrut, 'FM99G999G999', 'NLS_NUMERIC_CHARACTERS='',.''')      AS rut_trabajador,
    INITCAP(t.nombre || ' ' || t.appaterno || ' ' || t.apmaterno)           AS trabajador,
    be.descrip                                                               AS descrip,
    TO_CHAR(be.porc_bono, 'FM0000000')                                       AS pct_estudios,
    ROUND(t.sueldo_base, 0)                                                  AS sueldo_actual,
    ROUND(t.sueldo_base * (be.porc_bono / 100), 0)                           AS aumento,
    TO_CHAR(
        ROUND(t.sueldo_base * (1 + be.porc_bono / 100), 0),
        'FM$999G999G999',
        'NLS_NUMERIC_CHARACTERS='',.'''
    )                                                                        AS sueldo_aumentado
FROM trabajador t
JOIN syn_bono_escolar be
  ON be.id_escolar = t.id_escolaridad_t
JOIN syn_tipo_trab tt
  ON tt.id_categoria = t.id_categoria_t
LEFT JOIN (
    SELECT numrut_t, COUNT(*) AS cant_cargas
    FROM asignacion_familiar
    GROUP BY numrut_t
) af
  ON af.numrut_t = t.numrut
WHERE
    UPPER(tt.desc_categoria) = 'CAJERO'
    OR NVL(af.cant_cargas, 0) IN (1, 2);

--CONSULTA ETAPA 1
SELECT *
FROM v_aumentos_estudios
ORDER BY 4, 1;

--ETAPA 2
CREATE INDEX idx_trabajador_apm   ON trabajador(apmaterno);
CREATE INDEX idx_trabajador_apm_2 ON trabajador(UPPER(apmaterno));

EXEC DBMS_STATS.GATHER_TABLE_STATS(USER, 'TRABAJADOR', estimate_percent => 100);
EXEC DBMS_STATS.GATHER_INDEX_STATS(USER, 'IDX_TRABAJADOR_APM');
EXEC DBMS_STATS.GATHER_INDEX_STATS(USER, 'IDX_TRABAJADOR_APM_2');

DELETE FROM plan_table;

-- FIGURA 8 (sin UPPER)
EXPLAIN PLAN SET STATEMENT_ID='FIG8' FOR
SELECT t.numrut, t.fecnac, t.nombre, t.appaterno, t.apmaterno
FROM trabajador t
WHERE t.apmaterno = 'CASTILLO'
ORDER BY 3;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL,'FIG8','BASIC +PREDICATE'));

-- FIGURA 9 (con UPPER)
EXPLAIN PLAN SET STATEMENT_ID='FIG9' FOR
SELECT t.numrut, t.fecnac, t.nombre, t.appaterno, t.apmaterno
FROM trabajador t
WHERE UPPER(t.apmaterno) = 'CASTILLO'
ORDER BY 3;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL,'FIG9','BASIC +PREDICATE'));

-- VISTA CONFIRMADA
SELECT *
FROM v_aumentos_estudios
ORDER BY TO_NUMBER(pct_estudios) ASC, trabajador ASC;

