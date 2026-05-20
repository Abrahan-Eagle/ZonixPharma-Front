---
name: zonix-admin-analytics-ui
description: UI dashboards admin/commerce Zonix Pharma (Flutter). Métricas, tablas, filtros; alinear KPIs con zonix-analytics Backend.
trigger: Cuando se diseñen o modifiquen pantallas de analytics, reportes o dashboards (admin/commerce) en Flutter.
scope: lib/features/screens/admin/, lib/features/screens/commerce/, lib/features/services/analytics_service.dart
author: Zonix Team
version: 1.0
---

# UI de analytics (admin / commerce) — Zonix Pharma

## 1. Layout General

Estructura recomendada:

```text
AppBar: "Dashboard" o "Analytics"
Scroll:
  - Filtros (rango de fechas + selector de comercio si aplica)
  - Cards de métricas (fila o grid)
  - Gráfico(s) principal(es)
  - Tablas de detalle (órdenes, productos, comercios)
```

## 2. Filtros

- Rango de fechas:
  - Hoy / 7 días / 30 días / Personalizado.
- Opcional:
  - Selector de comercio (para admin viendo un commerce específico).
- Mostrar chips o dropdown, no recargar toda la pantalla bruscamente.

## 3. Cards de Métricas

Ejemplos típicos:

- Total de ventas (USD).
- Número de órdenes.
- Ticket promedio.
- Órdenes canceladas.
- Performance de delivery (tiempo medio).

Patrón visual:

- Fondo `surface` (claro u oscuro según tema).
- Ícono a la izquierda (ej. money, shopping_bag, timer).
- Valor grande (ej. `\$1,250.00`).
- Subtítulo pequeño (“Ventas últimos 7 días”).

## 4. Gráficos

Tipos recomendados:

- Línea o área: ventas por día.
- Barras: órdenes por estado, top productos, top comercios.

Buenas prácticas:

- Limitar cantidad de puntos (máx. 30).
- Mostrar leyenda clara.
- Permitir tap en barra o punto para ver detalle (tooltip).

## 5. Tablas de Detalle

Usos comunes:

- Lista de órdenes con columnas: ID, comercio, total, estado, fecha.
- Top productos: nombre, categoría, cantidad vendida, ingreso.
- Comercios: nombre, ventas, comisión, estado.

Recomendaciones:

- Paginación en frontend alineada con backend (ver `zonix-analytics` § 2).
- Ordenamiento por columnas clave (fecha, total, estado).

## 6. Estados de Carga

- **Loading**:
  - Shimmer en cards y barras placeholder.
- **Sin datos**:
  - Mensaje “No hay datos para este rango de fechas” + sugerir cambiar filtro.
- **Error**:
  - Banner rojo o SnackBar con texto corto + botón "Reintentar".

## 7. Cross-references

- **Consultas de analytics**: `zonix-analytics` (backend).
- **Pagos y montos**: `zonix-payments` § 5.
- **Estados de orden**: `zonix-order-lifecycle` § 1-2.

