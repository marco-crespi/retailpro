-- =====================================================
-- Practica - Modulo 2 Unidad 1: Diseno de esquemas con DDL
-- Autor: Marco Crespi
-- Carrera Data Analytics - Coderhouse
-- Motor destino: Microsoft SQL Server 2019 Express
-- =====================================================
-- Objetivo: definir la estructura (CREATE TABLE) de un
-- sistema de gestion de ventas, eligiendo el tipo de dato
-- adecuado para cada columna y justificando la decision.
-- =====================================================


-- Limpieza previa: permite re-ejecutar el script sin errores
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS productos;


-- =====================================================
-- TABLA CLIENTES
-- =====================================================
CREATE TABLE clientes (

    -- INT: identificador numerico entero. Es un contador
    -- secuencial, no un valor sobre el que se hagan
    -- operaciones aritmeticas (nunca se suma un ID con otro).
    -- INT admite hasta 2.147.483.647 registros, mas que
    -- suficiente para la base de clientes de una empresa.
    id_cliente      INT,

    -- VARCHAR(100): texto de largo variable. "VAR" indica
    -- que solo ocupa el espacio que realmente usa: si el
    -- nombre tiene 12 caracteres, se almacenan 12 y no 100.
    -- Un CHAR(100) reservaria los 100 caracteres en cada
    -- fila, rellenando el resto con espacios en blanco.
    -- 100 caracteres cubren nombre y apellido completos.
    nombre          VARCHAR(100),

    -- VARCHAR(MAX): texto de largo indefinido. A diferencia
    -- de las demas columnas, aca no se puede estimar un
    -- maximo razonable: una biografia puede ser una linea
    -- o varios parrafos.
    -- Se usa VARCHAR(MAX) y no TEXT porque TEXT esta
    -- deprecado en las versiones modernas de SQL Server.
    -- Importante: este tipo se reserva SOLO para campos
    -- realmente extensos. Aplicarlo a todas las columnas
    -- de texto consumiria memoria innecesaria y ralentizaria
    -- las busquedas.
    perfil_bio      VARCHAR(MAX),

    -- DATE: almacena unicamente ano, mes y dia. No se usa
    -- DATETIME porque la hora exacta del alta no aporta
    -- valor analitico, y el tipo mas chico reduce el tamano
    -- de la tabla.
    -- Guardar la fecha como VARCHAR seria un error: Power BI
    -- no la reconoceria como fecha y no se podrian usar las
    -- funciones de inteligencia temporal.
    fecha_registro  DATE

    -- Nota: la ultima columna NO lleva coma antes del
    -- parentesis de cierre.
    );


-- =====================================================
-- TABLA PRODUCTOS
-- =====================================================
CREATE TABLE productos (

    -- INT: mismo criterio que id_cliente. Identificador
    -- entero, sin decimales ni operaciones matematicas.
    id_producto     INT,

    -- VARCHAR(255): descripcion comercial del producto.
    -- 255 caracteres dan margen para nombres extensos
    -- ("Notebook Lenovo ThinkPad E14 Gen 4 16GB 512GB SSD")
    -- sin llegar al desperdicio de un VARCHAR(MAX).
    descripcion     VARCHAR(255),

    -- DECIMAL(10,2): 10 digitos en total, 2 de ellos
    -- decimales. Es el estandar para valores monetarios.
    -- NUNCA usar FLOAT para dinero: FLOAT guarda
    -- aproximaciones binarias y al sumar miles de
    -- transacciones acumula error (por ejemplo, 4999.9999997
    -- en lugar de 5000.00). DECIMAL es exacto.
    precio          DECIMAL(10,2),

    -- BIT: tipo binario que solo admite 0 o 1. Es la opcion
    -- correcta para un campo de dos estados: el producto
    -- esta a la venta o no lo esta, no hay valores
    -- intermedios.
    -- Por que BIT y no las alternativas:
    --   * SQL Server no tiene un tipo BOOLEAN nativo.
    --   * TINYINT funcionaria, pero admite de 0 a 255:
    --     seria dar 256 estados posibles a algo que
    --     necesita 2, y permitiria cargar valores invalidos.
    --   * CHAR(1) con 'S'/'N' es mas legible al leer la
    --     tabla en crudo, pero ocupa mas espacio y no impide
    --     que alguien inserte una 'X' por error.
    -- Convencion adoptada: 1 = disponible, 0 = descontinuado.
    esta_activo     BIT

    );
