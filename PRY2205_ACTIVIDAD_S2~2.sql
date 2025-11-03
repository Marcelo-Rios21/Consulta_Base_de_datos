-- CREACION DE TABLAS

--  TABLAS DE UBICACIÓN GEOGRÁFICA

CREATE TABLE ciudad (
    codciudad      NUMBER(2)     PRIMARY KEY,
    descripcion    VARCHAR2(30)
);

CREATE TABLE comuna (
    codcomuna      NUMBER(2)      PRIMARY KEY,
    descripcion    VARCHAR2(30),
    codciudad      NUMBER(2),
    CONSTRAINT cod_ciudad_fk FOREIGN KEY (codciudad)
        REFERENCES ciudad (codciudad)
);

--  TABLAS DE ESCOLARIDAD Y TRAMOS

CREATE TABLE escolaridad (
    id_escolaridad     NUMBER(2)     PRIMARY KEY,
    sigla_escolaridad  VARCHAR2(5),
    desc_escolaridad   VARCHAR2(50)
);

CREATE TABLE tramo_escolaridad (
    id_escolaridad         NUMBER(2),
    fecha_vigencia         NUMBER(4),
    porc_asig_escolaridad  NUMBER(2),
    CONSTRAINT pk_tramo_escolaridad PRIMARY KEY (id_escolaridad, fecha_vigencia),
    CONSTRAINT fk_tramo_escolaridad FOREIGN KEY (id_escolaridad)
        REFERENCES escolaridad (id_escolaridad)
);


--  TABLAS DE ANTIGÜEDAD DE VENDEDORES

CREATE TABLE tramo_antiguedad (
    sec_annos_contratado NUMBER(2),
    fec_ini_vig          DATE,
    fec_ter_vig          DATE,
    annos_cont_inf       NUMBER(2),
    annos_cont_sup       NUMBER(2),
    porcentaje           NUMBER(2),
    CONSTRAINT pk_tramo_antiguedad PRIMARY KEY (sec_annos_contratado, fec_ini_vig)
);

--  TABLAS DE REFERENCIA DE PRODUCTOS

CREATE TABLE unidad_medida (
    codunidad     VARCHAR2(2)     PRIMARY KEY,
    descripcion   VARCHAR2(30)
);

CREATE TABLE pais (
    codpais       NUMBER(2)       PRIMARY KEY,
    nompais       VARCHAR2(30)
);

CREATE TABLE producto (
    codproducto        NUMBER(3)       PRIMARY KEY,
    descripcion        VARCHAR2(40),
    codunidad          VARCHAR2(2),
    codcategoria       VARCHAR2(1),
    vunuario           NUMBER(8),
    valorcomprapeso    NUMBER(8),
    valorcompradolar   NUMBER(8,2),
    totalstock         NUMBER(5),
    stkseguridad       NUMBER(5),
    procedencia        VARCHAR2(1),
    codpais            NUMBER(2),
    codproducto_rel    NUMBER(3),
    CONSTRAINT cod_unidad_fk FOREIGN KEY (codunidad)
        REFERENCES unidad_medida (codunidad),
    CONSTRAINT cod_pais_fk FOREIGN KEY (codpais)
        REFERENCES pais (codpais),
    CONSTRAINT codproducto_rel_fk FOREIGN KEY (codproducto_rel)
        REFERENCES producto (codproducto)
);

--  TABLAS DE FORMAS DE PAGO Y BANCOS

CREATE TABLE forma_pago (
    codpago       NUMBER(2)     PRIMARY KEY,
    descripcion   VARCHAR2(30)
);

CREATE TABLE banco (
    codbanco      NUMBER(2)     PRIMARY KEY,
    descripcion   VARCHAR2(30)
);

--  TABLAS DE CLIENTES

CREATE TABLE cliente (
    rutcliente    VARCHAR2(10)  PRIMARY KEY,
    nombre        VARCHAR2(30),
    direccion     VARCHAR2(30),
    codcomuna     NUMBER(2),
    telefono      NUMBER(10),
    estado        VARCHAR2(1),
    mail          VARCHAR2(50),
    credito       NUMBER(7),
    saldo         NUMBER(7),
    CONSTRAINT cod_comuna_fk FOREIGN KEY (codcomuna)
        REFERENCES comuna (codcomuna)
);

--  TABLAS DE VENDEDORES Y REMUNERACIONES

CREATE TABLE vendedor (
    rutvendedor    VARCHAR2(10)  PRIMARY KEY,
    id             NUMBER(2),
    nombre         VARCHAR2(30),
    direccion      VARCHAR2(30),
    codcomuna      NUMBER(2),
    telefono       NUMBER(10),
    mail           VARCHAR2(50),
    sueldo_base    NUMBER(8),
    comision       NUMBER(2,2),
    fecha_contrato DATE,
    id_escolaridad NUMBER(2),
    CONSTRAINT vendedor_cod_comuna_fk FOREIGN KEY (codcomuna)
        REFERENCES comuna (codcomuna),
    CONSTRAINT fk_esc_vendedor FOREIGN KEY (id_escolaridad)
        REFERENCES escolaridad (id_escolaridad)
);

CREATE TABLE remun_mensual_vendedor (
    rutvendedor        VARCHAR2(10),
    nomvendedor        VARCHAR2(30),
    fecha_remun        NUMBER(6),
    sueldo_base        NUMBER(8),
    colacion           NUMBER(8),
    movilizacion       NUMBER(8),
    prevision          NUMBER(8),
    salud              NUMBER(8),
    comision_normal    NUMBER(8),
    comsion_por_venta  NUMBER(8),
    total_bonos        NUMBER(8),
    total_haberes      NUMBER(8),
    total_desctos      NUMBER(8),
    total_pagar        NUMBER(8),
    CONSTRAINT pk_remun_mensual_vendedor PRIMARY KEY (rutvendedor, fecha_remun),
    CONSTRAINT fk_remun_mensual_vendedor FOREIGN KEY (rutvendedor)
        REFERENCES vendedor (rutvendedor)
);

--  TABLAS DE TRANSACCIONES: FACTURA / DETALLE FACTURA

CREATE TABLE factura (
    numfactura       NUMBER(7)     PRIMARY KEY,
    rutcliente       VARCHAR2(10),
    rutvendedor      VARCHAR2(10),
    fecha            DATE,
    f_vencimiento    DATE,
    neto             NUMBER(7),
    iva              NUMBER(7),
    total            NUMBER(7),
    codbanco         NUMBER(2),
    codpago          NUMBER(2),
    num_docto_pago   VARCHAR2(30),
    estado           VARCHAR2(2),
    CONSTRAINT rutcliente_fk FOREIGN KEY (rutcliente)
        REFERENCES cliente (rutcliente),
    CONSTRAINT rutvendedor_fk FOREIGN KEY (rutvendedor)
        REFERENCES vendedor (rutvendedor),
    CONSTRAINT codpago_fk FOREIGN KEY (codpago)
        REFERENCES forma_pago (codpago),
    CONSTRAINT codbanco_fk FOREIGN KEY (codbanco)
        REFERENCES banco (codbanco)
);

CREATE TABLE detalle_factura (
    numfactura    NUMBER(7),
    codproducto   NUMBER(3),
    vunitario     NUMBER(8),
    codpromocion  NUMBER(4),
    descri_prom   VARCHAR2(60),
    descuento     NUMBER(8),
    cantidad      NUMBER(5),
    totallinea    NUMBER(8),
    CONSTRAINT pk_det_fact PRIMARY KEY (numfactura, codproducto),
    CONSTRAINT cod_prod_fk FOREIGN KEY (codproducto)
        REFERENCES producto (codproducto),
    CONSTRAINT num_fact_fk FOREIGN KEY (numfactura)
        REFERENCES factura (numfactura)
);

--  TABLAS DE TRANSACCIONES: BOLETA / DETALLE BOLETA

CREATE TABLE boleta (
    numboleta       NUMBER(7)     PRIMARY KEY,
    rutcliente      VARCHAR2(10),
    rutvendedor     VARCHAR2(10),
    fecha           DATE,
    total           NUMBER(7),
    codpago         NUMBER(2),
    codbanco        NUMBER(2),
    num_docto_pago  VARCHAR2(30),
    estado          VARCHAR2(2),
    CONSTRAINT bol_rutcliente_fk FOREIGN KEY (rutcliente)
        REFERENCES cliente (rutcliente),
    CONSTRAINT bol_rutvendedor_fk FOREIGN KEY (rutvendedor)
        REFERENCES vendedor (rutvendedor),
    CONSTRAINT bol_codpago_fk FOREIGN KEY (codpago)
        REFERENCES forma_pago (codpago),
    CONSTRAINT bol_codbanco_fk FOREIGN KEY (codbanco)
        REFERENCES banco (codbanco)
);

CREATE TABLE detalle_boleta (
    numboleta     NUMBER(7),
    codproducto   NUMBER(3),
    vunitario     NUMBER(8),
    codpromocion  NUMBER(4),
    descri_prom   VARCHAR2(60),
    descuento     NUMBER(8),
    cantidad      NUMBER(5),
    totallinea    NUMBER(8),
    CONSTRAINT pk_det_boleta PRIMARY KEY (numboleta, codproducto),
    CONSTRAINT det_bol_codproducto_fk FOREIGN KEY (codproducto)
        REFERENCES producto (codproducto),
    CONSTRAINT det_bol_num_boleta_fk FOREIGN KEY (numboleta)
        REFERENCES boleta (numboleta)
);

-- CASO 1

-- FORMAS DE PAGO
INSERT INTO forma_pago VALUES (1, 'EFECTIVO');
INSERT INTO forma_pago VALUES (2, 'TARJETA DEBITO');
INSERT INTO forma_pago VALUES (3, 'TARJETA CREDITO');
INSERT INTO forma_pago VALUES (4, 'CHEQUE');

-- BANCOS
INSERT INTO banco VALUES (1, 'BANCOESTADO');
INSERT INTO banco VALUES (2, 'SANTANDER');
INSERT INTO banco VALUES (3, 'BCI');

-- CLIENTES
INSERT INTO cliente (rutcliente, nombre, direccion, codcomuna, telefono, estado, mail, credito, saldo)
VALUES ('12444560-7', 'Carlos Peña', 'Av. Providencia 123', NULL, 998877665, NULL, 'carlos.pena@mail.cl', 500000, 120000);

INSERT INTO cliente (rutcliente, nombre, direccion, codcomuna, telefono, estado, mail, credito, saldo)
VALUES ('08125781-8', 'María Torres', 'Las Lilas 458', NULL, 956789321, NULL, 'maria.torres@mail.cl', 800000, 450000);

INSERT INTO cliente (rutcliente, nombre, direccion, codcomuna, telefono, estado, mail, credito, saldo)
VALUES ('05446780-0', 'Ricardo López', 'San Diego 998', NULL, 912345678, NULL, 'ricardo.lopez@mail.cl', 600000, 250000);

INSERT INTO cliente (rutcliente, nombre, direccion, codcomuna, telefono, estado, mail, credito, saldo)
VALUES ('13685017-1', 'Paula Fuentes', 'Av. La Florida 77', NULL, 933221100, NULL, 'paula.fuentes@mail.cl', 700000, 300000);

-- FACTURAS 
INSERT INTO factura (numfactura, rutcliente, fecha, neto, iva, total, codbanco, codpago)
VALUES (11530, '12444560-7', TO_DATE('08-03-2024', 'DD-MM-YYYY'), 27000, 5130, 32130, 1, 1);

INSERT INTO factura (numfactura, rutcliente, fecha, neto, iva, total, codbanco, codpago)
VALUES (11529, '08125781-8', TO_DATE('08-03-2024', 'DD-MM-YYYY'), 21900, 4161, 26061, 1, 1);

INSERT INTO factura (numfactura, rutcliente, fecha, neto, iva, total, codbanco, codpago)
VALUES (11528, '05446780-0', TO_DATE('07-03-2024', 'DD-MM-YYYY'), 29700, 5643, 35343, 1, 4);

INSERT INTO factura (numfactura, rutcliente, fecha, neto, iva, total, codbanco, codpago)
VALUES (11527, '08125781-8', TO_DATE('07-03-2024', 'DD-MM-YYYY'), 29700, 5643, 35343, 1, 1);

INSERT INTO factura (numfactura, rutcliente, fecha, neto, iva, total, codbanco, codpago)
VALUES (11526, '13685017-1', TO_DATE('17-02-2024', 'DD-MM-YYYY'), 29700, 5643, 35343, 2, 3);

INSERT INTO factura (numfactura, rutcliente, fecha, neto, iva, total, codbanco, codpago)
VALUES (11525, '08125781-8', TO_DATE('16-02-2024', 'DD-MM-YYYY'), 30000, 5700, 35700, 2, 4);

INSERT INTO factura (numfactura, rutcliente, fecha, neto, iva, total, codbanco, codpago)
VALUES (11524, '12444560-7', TO_DATE('15-02-2024', 'DD-MM-YYYY'), 58455, 11606, 69561, 3, 4);

INSERT INTO factura (numfactura, rutcliente, fecha, neto, iva, total, codbanco, codpago)
VALUES (11523, '05446780-0', TO_DATE('04-02-2024', 'DD-MM-YYYY'), 37500, 7125, 44625, 3, 1);

INSERT INTO factura (numfactura, rutcliente, fecha, neto, iva, total, codbanco, codpago)
VALUES (11522, '08125781-8', TO_DATE('03-02-2024', 'DD-MM-YYYY'), 209400, 39786, 249186, 3, 3);

COMMIT;

-- CONSULTA CASO 1

SELECT
  f.numfactura AS "N° Factura",
  LOWER(TO_CHAR(f.fecha,'DD "de" Month YYYY','NLS_DATE_LANGUAGE=Spanish')) AS "Fecha Emisión",
  LPAD(f.rutcliente,10,'0') AS "RUT Cliente",
  TO_CHAR(NVL(f.neto,0),'FM$999G999G999','NLS_NUMERIC_CHARACTERS=,.') AS "Monto Neto",
  TO_CHAR(NVL(f.iva,0),'FM$999G999G999','NLS_NUMERIC_CHARACTERS=,.') AS "Monto IVA",
  TO_CHAR(NVL(f.total,NVL(f.neto,0)+NVL(f.iva,0)),'FM$999G999G999','NLS_NUMERIC_CHARACTERS=,.') AS "Total Factura",
  CASE
    WHEN NVL(f.total,0) BETWEEN 0 AND 50000 THEN 'Bajo'
    WHEN NVL(f.total,0) BETWEEN 50001 AND 100000 THEN 'Medio'
    ELSE 'Alto'
  END AS "Categoría Monto",
  CASE f.codpago
    WHEN 1 THEN 'EFECTIVO'
    WHEN 2 THEN 'TARJETA DEBITO'
    WHEN 3 THEN 'TARJETA CREDITO'
    ELSE 'CHEQUE'
  END AS "Forma de pago"
FROM factura f
WHERE EXTRACT(YEAR FROM f.fecha)=EXTRACT(YEAR FROM ADD_MONTHS(SYSDATE,-12))
ORDER BY f.fecha DESC, f.neto DESC;
  

-- CASO 2

-- COMUNAS
INSERT INTO comuna (codcomuna, descripcion, codciudad)
VALUES (1, 'Santiago Centro', NULL);
INSERT INTO comuna (codcomuna, descripcion, codciudad)
VALUES (2, 'Providencia', NULL);
INSERT INTO comuna (codcomuna, descripcion, codciudad)
VALUES (4, 'Ñuñoa', NULL);
INSERT INTO comuna (codcomuna, descripcion, codciudad)
VALUES (8, 'La Florida', NULL);

-- CLIENTES
MERGE INTO cliente c
USING (
  SELECT '13746912-9' rutcliente, 'Abraham Iglesias' nombre, 91452303 telefono, 4 codcomuna,
         'abraham.iglesias@yahoo.com' mail, 1000000 credito, 950000 saldo, 'A' estado FROM dual UNION ALL
  SELECT '11755017-K','Andrea Lara',       8548619,  NULL, 'andrea.lara@gmail.com',     2000000, 1800000,'A' FROM dual UNION ALL
  SELECT '5446780-0', 'Carlos Mendoza',     NULL, 1,  NULL,                             1100000, 550000,  'A' FROM dual UNION ALL
  SELECT '10675908-1','Jaime Salamanca',   78598555, NULL, 'jaime.salamanca@gmail.com',  850000, 800000,  'A' FROM dual UNION ALL
  SELECT '13685017-1','Johnny Yanez',      78598619, NULL, 'johnny.yanez@gmail.com',    2000000, 1000000, 'A' FROM dual UNION ALL
  SELECT '6245678-1', 'Juan Lopez',        96644123, 8,   'juan.lopez@gmail.com',       1393100, 696550,  'A' FROM dual UNION ALL
  SELECT '10812874-0','Lidia Fuenzalida',  78544452, NULL, 'lidia.fuenzalida@gmail.com', 2220000,1110000, 'A' FROM dual UNION ALL
  SELECT '11245678-5','Marco Iturra',      94577804, 8,   NULL,                         4664820,2332410,  'A' FROM dual UNION ALL
  SELECT '7812354-2', 'Maria Santander',  961682456, 8,   'maria.santander@hotmail.com', 1000000, 900000,  'A' FROM dual UNION ALL
  SELECT '6467708-6', 'Maribel Soto',      95115445, 4,   'maribel.soto@gmail.com',      2400000,1200000,  'A' FROM dual UNION ALL
  SELECT '14456789-4','Oscar Lara',        79882222, NULL, 'oscar.lara@gmail.com',       4000000,2000000,  'A' FROM dual UNION ALL
  SELECT '8125781-8', 'Patricia Fuentes',  NULL, 2,   'patricia.fuentes@hotmail.com',     800000, 400000,  'A' FROM dual UNION ALL
  SELECT '10125945-7','Sabina Vergara',    88656285, 4,   NULL,                          700000, 350000,  'A' FROM dual
) d
ON (c.rutcliente = d.rutcliente)
WHEN MATCHED THEN
  UPDATE SET c.nombre     = d.nombre,
             c.telefono   = d.telefono,
             c.codcomuna  = d.codcomuna,
             c.mail       = d.mail,
             c.credito    = d.credito,
             c.saldo      = d.saldo,
             c.estado     = d.estado
WHEN NOT MATCHED THEN
  INSERT (rutcliente, nombre, telefono, codcomuna, mail, credito, saldo, estado)
  VALUES (d.rutcliente, d.nombre, d.telefono, d.codcomuna, d.mail, d.credito, d.saldo, d.estado);

COMMIT;

-- CONSULTA CASO 2
SELECT
  LPAD(rutcliente, 12, '*') AS "RUT",
  INITCAP(nombre)                             AS "Cliente",
  NVL(TO_CHAR(telefono), 'Sin teléfono')      AS "TELÉFONO",
  NVL(TO_CHAR(codcomuna), 'Sin comuna')       AS "COMUNA",
  estado                                      AS "ESTADO",
  CASE
    WHEN (saldo / NULLIF(credito,0)) * 100 > 80 THEN 'Crítico'
    WHEN (saldo / NULLIF(credito,0)) * 100 BETWEEN 50 AND 80
         THEN 'Regular ( ' ||
              TO_CHAR(saldo, 'FM$999G999G999','NLS_NUMERIC_CHARACTERS=,.') ||
              ' )'
    ELSE 'Bueno ( ' ||
         TO_CHAR(credito - saldo, 'FM$999G999G999','NLS_NUMERIC_CHARACTERS=,.') ||
         ' )'
  END                                         AS "Estado Crédito",
  UPPER(
    NVL(SUBSTR(mail, INSTR(mail,'@')+1), 'Correo no registrado')
  )                                           AS "Dominio Correo"
FROM cliente
WHERE estado = 'A'
  AND credito > 0
ORDER BY nombre ASC;

-- CASO 3
INSERT INTO unidad_medida (codunidad, descripcion) VALUES ('UN', 'Unidad');
INSERT INTO pais (codpais, nompais) VALUES (1, 'Importado');

-- PRODUCTOS
INSERT INTO producto (
  codproducto, descripcion, codunidad, codcategoria,
  vunuario, valorcomprapeso, valorcompradolar, totalstock,
  stkseguridad, procedencia, codpais, codproducto_rel
) VALUES (1, 'Zapato Hombre Modelo All Black-0-11', 'UN', 'A', 25000, NULL, 7.42, 100, 20, 'i', 1, NULL);

INSERT INTO producto VALUES (2, 'Zapato Hombre Modelo Lago 6-05', 'UN', 'A', 28000, NULL, 8.87, 90, 20, 'i', 1, NULL);
INSERT INTO producto VALUES (3, 'Zapato Hombre Modelo Padua 6-43', 'UN', 'A', 26000, NULL, 7.09, 54, 20, 'i', 1, NULL);
INSERT INTO producto VALUES (4, 'Zapato Hombre Modelo Dozza 0-23', 'UN', 'A', 27000, NULL, 6.86, 40, 20, 'i', 1, NULL);
INSERT INTO producto VALUES (5, 'Zapato Hombre Modelo Valier 3-18', 'UN', 'A', 23000, NULL, 4.03, 40, 20, 'i', 1, NULL);
INSERT INTO producto VALUES (6, 'Zapato Hombre Modelo Murcia 0-003', 'UN', 'A', 42000, NULL, 7.98, 60, 20, 'i', 1, NULL);
INSERT INTO producto VALUES (7, 'Zapato Hombre Modelo Siena 0-01', 'UN', 'A', 41990, NULL, 9.77, 87, 20, 'i', 1, NULL);
INSERT INTO producto VALUES (8, 'Zapato Hombre Modelo Tago 0-87', 'UN', 'A', 24000, NULL, NULL, 60, 20, 'i', 1, NULL);
INSERT INTO producto VALUES (9, 'Zapato Hombre Modelo Tito 0-16', 'UN', 'A', 27500, NULL, 17.85, 18, 20, 'i', 1, NULL);
INSERT INTO producto VALUES (10, 'Zapato Hombre Modelo Napoles 0-17', 'UN', 'A', 27500, NULL, 2.01, 100, 20, 'i', 1, NULL);

-- PRODUCTO 11 QUE NO SALDRÁ
INSERT INTO producto VALUES (11, 'Zapato Nacional Modelo Andes 7-11', 'UN', 'A', 25000, NULL, 7.50, 45, 20, 'n', 1, NULL);

INSERT INTO producto VALUES (12, 'Zapato Mujer Modelo Bossa 0-18', 'UN', 'A', 30000, NULL, 15.64, 70, 20, 'i', 1, NULL);
INSERT INTO producto VALUES (13, 'Zapato Mujer Modelo Bristol 1-19', 'UN', 'A', 28000, NULL, NULL, 69, 20, 'i', 1, NULL);
INSERT INTO producto VALUES (14, 'Zapato Mujer Modelo Ramblas 2-20', 'UN', 'A', 43000, NULL, 15.85, 35, 20, 'i', 1, NULL);
INSERT INTO producto VALUES (15, 'Zapato Mujer Modelo Montreal 3-201', 'UN', 'A', 25000, NULL, 8.77, 20, 20, 'i', 1, NULL);
INSERT INTO producto VALUES (16, 'Zapato Mujer Modelo Montecarlo 4-10', 'UN', 'A', 25500, NULL, 5.50, 54, 20, 'i', 1, NULL);
INSERT INTO producto VALUES (17, 'Zapato Mujer Modelo Lombardo 11-5', 'UN', 'A', 26500, NULL, NULL, 34, 20, 'i', 1, NULL);
INSERT INTO producto VALUES (18, 'Zapato Mujer Modelo Sydney 12-6', 'UN', 'A', 26000, NULL, 6.80, 25, 20, 'i', 1, NULL);


COMMIT;

-- CONSULTA CASO 3
DEFINE TIPOCAMBIO_DOLAR = 950
DEFINE UMBRAL_BAJO = 35
DEFINE UMBRAL_ALTO = 65

SELECT
  p.codproducto AS "ID",
  p.descripcion AS "Descripción de Producto",

  CASE
    WHEN p.valorcompradolar IS NULL THEN 'Sin registro'
    ELSE RTRIM(RTRIM(
           TO_CHAR(p.valorcompradolar,
                   'FM9990D00',
                   'NLS_NUMERIC_CHARACTERS=.,'),
           '0'),
         '.') || ' USD'
  END AS "Compra en USD",

  CASE
    WHEN p.valorcompradolar IS NULL THEN 'Sin registro'
    ELSE TO_CHAR(
           ROUND(p.valorcompradolar * &TIPOCAMBIO_DOLAR, 0),
           'FM$999G999',
           'NLS_NUMERIC_CHARACTERS=,.'
         ) || ' PESOS'
  END AS "USD convertido",

  NVL(TO_CHAR(p.totalstock), 'Sin registro') AS "Stock",

  CASE
    WHEN p.totalstock IS NULL THEN 'Sin datos'
    WHEN p.totalstock <= &UMBRAL_BAJO THEN '¡ALERTA stock muy bajo!'
    WHEN p.totalstock >  &UMBRAL_ALTO THEN 'OK'
    ELSE '¡Reabastecer pronto!'
  END AS "Alerta Stock",

  CASE 
    WHEN p.totalstock > 80 THEN 
         TO_CHAR(ROUND(p.vunuario * 0.9, 0),
                 'FM$999G999',
                 'NLS_NUMERIC_CHARACTERS=,.')
    ELSE 'N/A'
  END AS "Precio Oferta"

FROM producto p
WHERE LOWER(p.descripcion) LIKE '%zapato%'
  AND p.procedencia = 'i'
ORDER BY p.codproducto DESC;


