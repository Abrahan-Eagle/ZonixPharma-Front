---
name: zonix-ui-design
description: Sistema de diseño visual de Zonix Pharma. Paleta fría Pharma (navy + teal + mint), tipografía Plus Jakarta Sans, cards de medicamento, badges Rx / cold chain / controlado, bottom nav por rol incluido pharmacist, layouts de receta médica.
trigger: Cuando se diseñe o construya UI, pantallas, widgets, cards, botones, o cualquier componente visual de la app. Incluye pantallas Rx, validación farmacéutica, cold chain.
scope: lib/features/screens/, lib/features/widgets/, lib/features/utils/app_colors.dart, lib/features/utils/app_theme.dart
author: Zonix Team
version: 3.0
---

# Zonix Pharma — Sistema de Diseño (Flutter)

> Marketplace farmacéutico digital del ecosistema Zonix (vertical Pharma, no Eats).
> Fuente canónica de marca: [`docs/BRAND_ZONIX_PHARMA.md`](../../../../ZonixPharma-Backend/docs/BRAND_ZONIX_PHARMA.md).
> Tokens implementados: [`lib/features/utils/app_colors.dart`](../../../lib/features/utils/app_colors.dart).
> Tema: [`lib/features/utils/app_theme.dart`](../../../lib/features/utils/app_theme.dart).

## 1. Paleta de Colores (canónica)

Usar SIEMPRE los tokens `AppColors.brand*` (o helpers `AppColors.scaffoldBg/cardBg/primaryText/secondaryText`). NUNCA `Colors.<name>` ni `Color(0x...)` en pantallas ni widgets.

| Token                   | Hex       | Uso                                                           |
| ----------------------- | --------- | ------------------------------------------------------------- |
| `brandNavy`             | `#1E2A5A` | Primario: AppBar, headers, iconos activos, CTAs secundarios   |
| `brandTealDeep`         | `#0F4C5C` | Acentos profundos, texto secundario sobre claro, badge Rx     |
| `brandTeal`             | `#56C7B8` | CTA principal (carrito, pagar, validar), FAB, bottom-nav activo |
| `brandMint`             | `#A8DCCB` | Highlights, badges OK, fondos decorativos                     |
| `brandSurfaceLight`     | `#F5F7FA` | Canvas claro                                                  |
| `brandMutedGray`        | `#C7CFD9` | Bordes, dividers, iconos secundarios                          |
| `brandSurfaceDark`      | `#142033` | Canvas oscuro                                                 |
| `brandCtaAccent`        | `#F2A65A` | CTAs puntuales (sub-acción positiva), warnings sutiles        |

### Estados semánticos

| Token            | Hex       | Uso                                        |
| ---------------- | --------- | ------------------------------------------ |
| `statusInfo`     | `#3B82F6` | Banner informativo, links secundarios      |
| `statusSuccess`  | `#22C55E` | Totales, aprobación, disponibilidad        |
| `statusWarning`  | `#F59E0B` | Advertencias (cold chain, TTL receta)      |
| `statusError`    | `#EF4444` | Errores, receta rechazada, eliminar        |

### Aliases legacy

`AppColors.blue`, `AppColors.orange`, `AppColors.red`, `AppColors.green`, `AppColors.purple`, etc. se mantienen como aliases mapeados a tokens Pharma solo para no romper pantallas antiguas. **Prohibido añadir usos nuevos de aliases** — migrar el archivo afectado a `brand*`.

## 2. Tipografía y bordes

- **Font:** Plus Jakarta Sans (via `google_fonts`).
- **Cuerpo:** 14–16 px, line-height 1.4–1.5.
- **Encabezados:** 18–26 px, weights 700–900.
- **Cards:** `BorderRadius.circular(16)`–`20`, sombra suave.
- **Botones primarios:** radius 16 (pill: 28).
- **Controles +/-:** círculos, mínimo 36 px área táctil.
- **Padding lateral:** 20–24 px.
- **Ancho máximo mobile:** 360–414 px.

## 3. Componentes clave

### Card de medicamento (buyer)

- Imagen: `100 px` alto, `width: double.infinity`, `borderRadius: 12`.
- Nombre: 15 px, bold, `maxLines: 1`, ellipsis.
- Chip categoría (si aplica): fondo `brandCtaAccent.withValues(alpha: 0.15)`, texto `brandCtaAccent`.
- Rating: icono `star` (`brandTeal`), texto 11 px; envolver en `Expanded` para no desbordar cuando conviven con badges.
- **Badge "Receta"** (obligatorio si `product.requiresPrescription`):
  - Fondo `brandTealDeep.withValues(alpha: 0.12)`, texto `brandTealDeep`, weight 700, 10 px.
- **Badge "Controlado"** (si `product.controlledSubstance`):
  - Fondo `statusError.withValues(alpha: 0.12)`, texto `statusError`, weight 700.
- **Badge "Cadena de frío"** (si `product.coldChain`):
  - Fondo `statusInfo.withValues(alpha: 0.15)`, icono `ac_unit`, texto `statusInfo`.
- Presentación / principio activo: 11 px, color secundario, `maxLines: 1`, ellipsis.
- Precio: 18 px, weight 800, `brandCtaAccent` (fila anclada al final con `Expanded > Column(end) > Row`, precio en `Flexible`).
- Botón + (añadir): círculo 32 px, icono `add` en `brandTeal` sobre fondo `grayLight`.

### Botón principal (CTA)

- Ancho completo, altura ≈52 px.
- Color: `brandTeal` para acciones generales y pagar; `brandCtaAccent` para sub-acciones "claim" puntuales.
- Texto blanco, icono izquierdo (si aplica), weight 700, radius 16.

### Cards de información

- Fondo: `AppColors.cardBg(context)` (auto light/dark).
- Radius: 16–20.
- Sombra suave (en light), border `white12` en dark.
- Padding: 16–20.

### Badges

- `Principal` / `Activo` → `brandTeal`.
- `Nuevo` / `Promo` → `brandCtaAccent`.
- `Receta` → `brandTealDeep`.
- `Controlado` → `statusError`.
- `Cadena de frío` → `statusInfo`.
- Compactos: padding 6 h × 2 v, radius 6–8.

### Empty / Loading / Error

- **Loading:** `Shimmer` en cards con `baseColor: grayDark` / `highlightColor: bgDark` (dark) y `gray` / `grayLight` (light).
- **Vacío:** icono grande centrado, mensaje principal bold + secundario en `secondaryText(context)`, CTA si aplica.
- **Error:** texto `statusError`, icono `error_outline`.

## 4. Layouts por pantalla

### Buyer — Catálogo (`products_page.dart`)

```
Scaffold (BuyerShell header + bottom nav buyer)
├── SearchBar (grayDark/grayLight)
├── Chips categorías (horizontal scroll)
├── Banner promo (160 px, gradient + imagen)
├── Sección "Lo más pedido" + grid 2 cols (childAspectRatio 0.62)
└── Card medicamento (ver §3)
```

### Buyer — Detalle de producto (`product_detail_page.dart`)

```
AppBar (← + "Detalle" + ♡)
├── Imagen ~40% viewport, borderRadius inferior 20
├── Card info: nombre 22px + precio brandCtaAccent + link farmacia brandNavy
├── Badges: Receta / Controlado / Cadena de frío / Presentación
├── Descripción / principio activo / posología (2–4 líneas)
└── Barra fija: selector (- N +) + "Añadir al carrito" (brandTeal pill)
```

### Buyer — Carrito (`cart_page.dart`)

```
Header "Carrito"
├── Banner Rx (obligatorio si cartService.requiresPrescription):
│   brandTealDeep suave + icono receipt_long + "Tu pedido incluye medicamentos Rx"
├── Banner cold chain (si cartService.coldChainRequired):
│   statusInfo suave + icono ac_unit + "Requiere cadena de frío"
├── Lista cards producto (+/- controles, eliminar rojo)
├── Resumen (Total items + Total en statusSuccess)
└── CTA fija inferior: "Proceder al pago" (brandTeal)
```

### Buyer — Checkout (`checkout_page.dart`)

```
AppBar ("Checkout" + ←)
├── Resumen compra (cards compactas)
├── Banner Rx + banner cold chain (mismos que cart)
├── Tipo entrega: Recoger (brandNavy) | Envío (brandTeal)
│   — cold chain restringe delivery sin equipo
├── Dirección (si envío): cards seleccionables con check brandTeal
├── Desglose: Subtotal + Envío + Total (statusSuccess)
└── CTA "Confirmar compra" (brandTeal, spinner loading)
    Bloquea si falta receta aprobada y ZONIX_PHARMA_BLOCK_RX_WITHOUT_PRESCRIPTION
```

### Buyer — Recetas

```
PrescriptionUploadPage:
├── AppBar "Subir receta"
├── Preview imagen/PDF + botón cambiar
├── Campos: tipo (common/retained/special), médico, paciente, fecha
└── CTA "Enviar para validación" (brandTeal)

MyPrescriptionsPage:
├── Filtros: Pendiente | Aprobada | Rechazada | Expirada
└── Cards con status color (warning/success/error/mutedGray)
```

### Pharmacist — Panel (`pharmacist_dashboard_page.dart`)

```
AppBar "Panel farmacéutico"
├── Cards métricas grid 2×2: Pendientes, Validadas hoy, Rechazadas, TTL vencidas
├── Acceso rápido "Pendientes"
└── Últimas validaciones (lista)
```

### Pharmacist — Pendientes (`pending_validations_page.dart`)

```
Lista de recetas pendientes:
├── Card por receta: imagen thumbnail + paciente + timer TTL
└── Tap → ValidationDetailPage
```

### Pharmacist — Detalle (`validation_detail_page.dart`)

```
AppBar receta #ID
├── Viewer imagen/PDF
├── Datos: paciente, médico, productos Rx del pedido
└── CTAs: "Aprobar" (statusSuccess) | "Rechazar" (statusError)
   Modal rechazo con motivo (requerido).
```

### Commerce — Dashboard (`commerce_dashboard_page.dart`)

```
Header con nombre farmacia + pharmacist_in_charge
├── Cards métricas: órdenes hoy, ingresos, productos Rx activos, lotes por vencer
├── Lista últimas órdenes (con badge si requires_prescription)
└── Alertas: stock bajo, recetas pendientes
```

### Admin — Dashboard (`admin_dashboard_page.dart`)

```
AppBar "Panel Admin"
├── Cards métricas grid cols responsivas (childAspectRatio ≥0.68 con FittedBox)
├── Gráficos: órdenes, revenue, delivery activos
└── Banner "Salud del sistema" (gradient brandTeal/brandNavy)
```

## 5. Navegación por rol (bottom nav)

Alineado con [`lib/app/main_router.dart`](../../../lib/app/main_router.dart).

| Rol              | Nivel | Bottom Nav                                                        |
| ---------------- | ----- | ----------------------------------------------------------------- |
| Buyer (`users`)  | 0     | Productos · Carrito · Mis Pedidos · Farmacias · Config            |
| Commerce         | 1     | Dashboard · Órdenes · Productos · Reportes · Config               |
| Delivery         | 2     | Entregas · Historial · Rutas · Ganancias · Config                 |
| Delivery Company | 3     | Dashboard · Agentes · Órdenes · Mapa · Config                     |
| Admin            | 4     | Dashboard · Usuarios · Órdenes · Analytics · Config               |
| Pharmacist       | 5     | Panel · Pendientes · Historial · Config                           |

Color activo: `brandTeal`; inactivo: `brandMutedGray`; fondo: `brandNavy` (dark) / `brandSurfaceLight` (light).

## 6. Estados de UI

Toda pantalla con datos debe manejar:

1. **Loading:** Shimmer / skeleton, nunca spinner a pantalla completa salvo transiciones.
2. **Vacío:** Ilustración + mensaje + CTA (si aplica).
3. **Error:** Texto `statusError` debajo del componente afectado.
4. **Éxito:** `statusSuccess` o `SnackBar` con fondo `brandTeal`.
5. **Deshabilitado:** Botón `brandMutedGray` + texto "No disponible".

## 7. Reglas farmacéuticas en UI

| Regla | UI esperada |
| ----- | ----------- |
| `product.requiresPrescription` | Badge "Receta" teal deep en card y detalle |
| `product.controlledSubstance` | Badge rojo "Controlado" + sugerir pickup en detalle |
| `product.coldChain` | Badge info "Cadena de frío" + advertencia en checkout |
| `cartService.requiresPrescription` | Banner en cart_page y checkout_page; bloquear "Pagar" si el pedido no tiene receta aprobada |
| `cartService.coldChainRequired` | Advertencia en checkout + restringir modo delivery sin equipo |
| `order.status == 'pending_prescription_validation'` | Timeline ampliado en detalle de orden + empty "Esperando validación del farmacéutico" |
| `prescription.status` | `pending_validation` (warning), `approved` (success), `rejected` (error), `expired` (muted) |

## 8. Reglas de tokens (obligatorias)

1. **Prohibido** `Colors.<name>` en `lib/features/screens/**` y `lib/features/widgets/**` (excepto `Colors.transparent`, `Colors.white*`, `Colors.black*` que ya están expuestos como `AppColors.white` / `AppColors.black*`).
2. **Prohibido** `Color(0xAARRGGBB)` literal fuera de `app_colors.dart` y `app_theme.dart`.
3. Usar siempre:
   - `AppColors.brand*` (tokens Pharma).
   - `AppColors.scaffoldBg(context)` / `cardBg(context)` / `primaryText(context)` / `secondaryText(context)` (helpers light/dark).
   - `Theme.of(context).colorScheme.<role>` cuando el widget lo admita.
4. **Migración** de aliases legacy: al tocar un archivo, sustituir `AppColors.blue` → `brandTeal`, `orange` → `brandCtaAccent`, `red` → `statusError`, `green` → `statusSuccess`, `yellow/amber` → `statusWarning` o `brandCtaAccent` según contexto.
5. **Copy**: nunca "restaurante/cocina/cuisine/hamburguesa/pizza/eats" en UI. Usar "farmacia", "especialidad", "medicamento", "receta".

## 9. Cross-references

- **Brand canónica:** `docs/BRAND_ZONIX_PHARMA.md` (backend repo).
- **Onboarding por rol (incluye pharmacist):** `zonix-onboarding`.
- **Checkout / pagos:** `zonix-payments`.
- **Estados de orden (incluye `pending_prescription_validation`):** `zonix-order-lifecycle`.
- **Eventos en tiempo real:** `zonix-realtime-events`.
