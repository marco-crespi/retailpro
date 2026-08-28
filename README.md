# RetailPro — Proyecto Integrador

**Marco Crespi** · Carrera Data Analytics · Coderhouse

Base de datos relacional para el análisis comercial de RetailPro, una empresa distribuidora
de tecnología. Este repositorio corresponde al **Módulo 3: Script SQL (DDL + DML)**.

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

| Archivo | Descripción |
|---|---|
| `retailpro_ddl_dml.sql` | Script completo: creación de tablas (DDL) + carga de datos (DML) |
| `README.md` | Este archivo |

---

## Modelo de datos

Cuatro tablas en Tercera Forma Normal (3NF). `ventas` es la tabla de hechos: la única que
contiene claves foráneas, conectando cada transacción con su cliente, producto y territorio.

```
   clientes            productos           territorios
  (id_cliente)       (id_producto)       (id_territorio)
       │                   │                    │
       └───────────────────┼────────────────────┘
                           │
                        ventas
                      (id_venta)
```

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
| `nombre_producto` | VARCHAR(150) | |
| `categoria` | VARCHAR(100) | Computo · Accesorios · Impresion · Redes · Software |
| `subcategoria` | VARCHAR(100) | |
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
| `clientes` | 30 |
| `productos` | 25 |
| `territorios` | 8 |
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

Luego ejecutar `retailpro_ddl_dml.sql` completo. El script respeta el orden de dependencias:
las tres tablas de referencia se crean y se cargan antes que `ventas`, ya que las claves
foráneas exigen que los identificadores referenciados existan previamente.

Las inserciones de `ventas` están divididas en lotes de 200 filas porque SQL Server admite
un máximo de 1.000 constructores de fila por sentencia `INSERT ... VALUES`.

### Verificación

```sql
SELECT 'clientes' AS tabla, COUNT(*) AS filas FROM clientes
UNION ALL SELECT 'productos', COUNT(*) FROM productos
UNION ALL SELECT 'territorios', COUNT(*) FROM territorios
UNION ALL SELECT 'ventas', COUNT(*) FROM ventas;
```

Para comprobar que las claves foráneas están activas, la siguiente inserción debe ser
rechazada (el cliente 9999 no existe):

```sql
INSERT INTO ventas (id_venta, fecha_venta, id_cliente, id_producto, id_territorio, cantidad, total_venta, canal)
VALUES (9999, '2025-12-01', 9999, 1, 1, 1, 1250.00, 'E-commerce');
```

---

## KPIs definidos en el Módulo 1

| KPI | Fórmula |
|---|---|
| Total Ventas | `SUM(total_venta)` |
| Margen Bruto (%) | `SUM(total_venta - costo * cantidad) / SUM(total_venta) * 100` |
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
