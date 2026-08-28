# RetailPro — Proyecto Integrador

**Marco Crespi** · Carrera Data Analytics · Coderhouse

Base de datos relacional para el análisis comercial de RetailPro, una empresa distribuidora
de tecnología. Este repositorio corresponde al **Checkpoint del Módulo 3: Script SQL de
Ingeniería de Datos**.

---

## Problema de negocio

RetailPro acumula años de datos de ventas en planillas de Excel desorganizadas. A pesar de
mantener un volumen estable de transacciones, la gerencia detectó que ciertos territorios y
canales muestran **márgenes decrecientes** sin una explicación clara.

> ¿Por qué ciertos territorios y canales de venta muestran márgenes decrecientes a pesar de
> mantener volumen de transacciones, y qué combinación de categoría de producto y segmento
> de cliente lo explica?

Este script construye la base de datos normalizada que permite responder esa pregunta.

---

## Contenido del repositorio

| Archivo | Módulo | Descripción |
|---|---|---|
| `modulo2/modulo2_unidad1_diseno.sql` | M2 · Unidad 1 | Práctica de diseño de esquemas: `CREATE TABLE` de `clientes` y `productos` con justificación de cada tipo de dato |
| `modulo3/ventas_tech_db.sql` | M3 · Checkpoint | Script completo del proyecto: DROP + DDL + DML + consultas de validación |
| `README.md` | — | Este archivo |

> El entregable principal del proyecto integrador es
> **`modulo3/ventas_tech_db.sql`**. El archivo de `modulo2/` corresponde a un
> ejercicio de práctica independiente, con su propio enunciado y sus propias tablas.

El script del Módulo 3 está dividido en cuatro secciones comentadas:

1. **DROP** — elimina las tablas si existen, en orden inverso a las dependencias
2. **DDL** — crea las cinco tablas con sus PK, FK y restricciones `NOT NULL`
3. **DML** — carga los datos iniciales
4. **SELECT** — consultas de validación de la carga

Gracias a la sección 1, el script es **repetible**: puede ejecutarse varias veces seguidas
sin errores de "objeto ya existente".

---

## Modelo de datos

Cinco tablas en Tercera Forma Normal (3NF). `ventas` es la tabla de hechos: contiene las
métricas numéricas y las claves foráneas que la conectan con cada dimensión.

```
   categorias
  (id_categoria)
        │
        ▼
   productos          clientes          territorios
  (id_producto)     (id_cliente)      (id_territorio)
        │                 │                  │
        └─────────────────┼──────────────────┘
                          │
                       ventas
                     (id_venta)
```

### categorias

| Columna | Tipo | Rol |
|---|---|---|
| `id_categoria` | INT | PK |
| `nombre_categoria` | VARCHAR(50) | NOT NULL |
| `descripcion` | VARCHAR(200) | |

### clientes

| Columna | Tipo | Rol |
|---|---|---|
| `id_cliente` | INT | PK |
| `nombre` | VARCHAR(100) | |
| `email` | VARCHAR(150) | |
| `ciudad` | VARCHAR(100) | |
| `segmento` | VARCHAR(50) | Corporativo · Mayorista · Retail |
| `fecha_registro` | DATE | |

### productos

| Columna | Tipo | Rol |
|---|---|---|
| `id_producto` | INT | PK |
| `nombre_producto` | VARCHAR(150) | NOT NULL |
| `id_categoria` | INT | FK → `categorias` |
| `precio` | DECIMAL(10,2) | Precio de venta |
| `costo` | DECIMAL(10,2) | Costo de adquisición |

### territorios

| Columna | Tipo | Rol |
|---|---|---|
| `id_territorio` | INT | PK |
| `region` | VARCHAR(100) | Sur · Este · Norte · Litoral · Centro |
| `pais` | VARCHAR(100) | |
| `zona` | VARCHAR(100) | |

### ventas

| Columna | Tipo | Rol |
|---|---|---|
| `id_venta` | INT | PK |
| `fecha_venta` | DATE | |
| `id_cliente` | INT | FK → `clientes` |
| `id_producto` | INT | FK → `productos` |
| `id_territorio` | INT | FK → `territorios` |
| `cantidad` | INT | |
| `total_venta` | DECIMAL(10,2) | = `cantidad` × `precio` |
| `canal` | VARCHAR(50) | Tienda Fisica · E-commerce · Distribuidores · Corporativo · Mayoristas |

---

## Decisiones de diseño

**Cinco tablas en lugar de cuatro.** El enunciado del checkpoint pide como mínimo
`categorias`, `productos`, `clientes` y `ventas`. Este modelo incluye además `territorios`,
porque el Módulo 1 definió *Rentabilidad por territorio* como uno de los KPIs del proyecto y
el boceto del dashboard incluye un mapa de calor geográfico. Guardar la región como texto
dentro de `ventas` habría reintroducido el mismo problema de normalización que se corrige en
`categorias`, de modo que se resolvió como dimensión propia con su clave foránea.

**La categoría es una tabla, no un texto.** Guardar el nombre de la categoría dentro de
`productos` genera una dependencia transitiva: un atributo que no es clave determinaría a
otro atributo que tampoco es clave, lo que rompe la 3NF. Además obligaría a un `UPDATE`
masivo cada vez que una categoría cambie de nombre, con el riesgo de dejar filas
desincronizadas. Separarla en `categorias` y referenciarla por `id_categoria` elimina el
problema.

**`DECIMAL(10,2)` para valores monetarios, no `FLOAT`.** `FLOAT` almacena aproximaciones
binarias: al sumar miles de transacciones acumula error. Para dinero se requiere precisión
exacta.

**`DATE` en lugar de `DATETIME`.** No se registra la hora de las operaciones, y usar el tipo
más chico posible reduce el tamaño de la tabla y acelera las consultas.

**IDs como `INT`.** Son identificadores para conteo y relación, no valores sobre los que se
opere aritméticamente.

**`VARCHAR` en lugar de `CHAR`.** Los nombres y direcciones tienen largo variable; `CHAR`
reservaría el espacio completo en cada fila.

**Restricciones nombradas.** Cada PK y FK lleva un nombre explícito (`PK_clientes`,
`FK_ventas_productos`) para que los errores de integridad identifiquen la restricción exacta
que falló.

**`NOT NULL` en los campos críticos.** Los tres IDs foráneos y `total_venta` son obligatorios:
sin ellos la transacción quedaría huérfana o rompería los cálculos de facturación.

**Sin tildes ni caracteres especiales.** Evita problemas de codificación entre distintas
configuraciones regionales de SQL Server.

---

## Datos cargados

| Tabla | Filas |
|---|---|
| `categorias` | 5 |
| `clientes` | 30 |
| `territorios` | 8 |
| `productos` | 25 |
| `ventas` | 1.000 |

Período cubierto: **enero 2024 – noviembre 2025**.

Los datos son sintéticos pero internamente coherentes: `total_venta` corresponde exactamente
al producto de `cantidad` por el `precio` del artículo en todas las filas, y las fechas de
venta son posteriores a la fecha de registro de cada cliente.

---

## Cómo ejecutar

Requiere **Microsoft SQL Server 2019** o superior.

```sql
CREATE DATABASE RetailPro;
GO
USE RetailPro;
GO
```

Luego ejecutar `modulo3/ventas_tech_db.sql` completo. El script respeta el orden de
dependencias: las tablas de dimensión se crean y se cargan antes que `ventas`, ya que las
claves foráneas exigen que los identificadores referenciados existan previamente. Las
sentencias `DROP` del inicio siguen el orden inverso por la misma razón.

Las inserciones de `ventas` están divididas en lotes de 200 filas porque SQL Server admite
un máximo de 1.000 constructores de fila por sentencia `INSERT ... VALUES`.

### Verificación

El propio script incluye las consultas de validación en su sección 4.

Para comprobar que las claves foráneas están activas, estas dos inserciones deben ser
**rechazadas** por el motor:

```sql
-- El cliente 9999 no existe
INSERT INTO ventas (id_venta, fecha_venta, id_cliente, id_producto, id_territorio, cantidad, total_venta, canal)
VALUES (9999, '2025-12-01', 9999, 1, 1, 1, 1250.00, 'E-commerce');

-- La categoria 99 no existe
INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, costo)
VALUES (999, 'Producto de prueba', 99, 10.00, 5.00);
```

---

## KPIs definidos en el Módulo 1

| KPI | Fórmula |
|---|---|
| Total Ventas | `SUM(total_venta)` |
| Margen Bruto (%) | `SUM(total_venta - costo * cantidad) / SUM(total_venta) * 100` (requiere JOIN con `productos`) |
| Ticket Promedio | `SUM(total_venta) / COUNT(id_venta)` |
| Clientes Activos | `COUNT(DISTINCT id_cliente)` |
| Ventas por Canal | `SUM(total_venta)` agrupado por `canal` |
| Rentabilidad por Territorio | Margen bruto agrupado por `region` |

---

## Estado del proyecto

- [x] **M1** — Brief analítico: problema, fuentes, preguntas, KPIs y boceto de dashboard
- [x] **M2** — Modelo relacional en 3NF con diagrama ER
- [x] **M3** — Script SQL: DDL y DML
- [ ] **M4** — Consultas analíticas y dashboard en Power BI
