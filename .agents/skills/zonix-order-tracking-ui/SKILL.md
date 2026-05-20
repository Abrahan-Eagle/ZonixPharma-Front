---
name: zonix-order-tracking-ui
description: UI tracking de órdenes Zonix Pharma (Flutter). Estados Rx, timelines, mapa y pending_prescription_validation.
trigger: Cuando se diseñen o modifiquen pantallas de órdenes, historial, detalle de pedido o tracking en mapa.
scope: lib/features/screens/orders/, lib/features/services/order_service.dart, lib/features/services/tracking_service.dart
author: Zonix Team
version: 1.0
---

# UI de tracking de órdenes — Zonix Pharma

## 1. Mapeo de Estados → UI

Estados backend (ver `zonix-order-lifecycle` § 1):

```text
pending_payment → paid → processing → shipped → delivered
                                   ↘ cancelled
```

Colores recomendados:

| Estado           | Color UI      | Uso                             |
| ---------------- | ------------- | -------------------------------- |
| `pending_payment`| Naranja      | Advertencia / pendiente          |
| `paid`           | Azul         | Confirmado                       |
| `processing`     | Azul oscuro  | En preparación                   |
| `shipped`        | Morado       | En camino                        |
| `delivered`      | Verde        | Completado                       |
| `cancelled`      | Rojo         | Cancelado                        |

## 2. Lista de Órdenes

Layout sugerido:

```text
Card por orden:
- Encabezado: #ID + estado (chip de color)
- Subtítulo: nombre del comercio + fecha
- Body: total, método de pago, tipo de entrega (delivery/pickup)
- Footer: CTA "Ver detalle" o "Rastrear"
```

Patrón:

- Mostrar siempre **estado actual** con chip de color.
- Para estados `pending_payment`, mostrar CTA para subir comprobante o cancelar.
- Para `shipped`, CTA principal = "Ver tracking" (mapa).

## 3. Detalle de Orden + Timeline

Timeline horizontal o vertical con pasos:

1. Orden creada (`pending_payment`)
2. Pago confirmado (`paid`)
3. Preparando (`processing`)
4. En camino (`shipped`)
5. Entregada (`delivered`)

Cada paso:

- Icono (check, card, chef, moto, check-circle).
- Texto corto.
- Paso actual resaltado con color primario; los anteriores en verde; los futuros en gris.

## 4. Tracking en Mapa

Pantalla típica:

```text
AppBar: "Tracking de orden #ID"
Mapa: marcador de comercio + marcador de delivery + ruta (si existe)
Bottom sheet:
  - Estado actual + texto amigable
  - ETA (minutos aproximados)
  - Botón "Contactar" (si aplica)
```

Datos:

- Origen/destino y ruta vienen del backend (ver `zonix-delivery-system` § 3).
- Solo mostrar tracking si la orden está en `shipped`.

## 5. Estados Vacíos y Errores

- Sin órdenes:
  - Ilustración + texto "Aún no tienes órdenes" + CTA "Explorar restaurantes".
- Error de carga:
  - Texto rojo debajo de la sección afectada + botón "Reintentar".

## 6. Cross-references

- **Estados de orden**: `zonix-order-lifecycle` § 1-2.
- **Rutas y distancias**: `zonix-delivery-system` § 3.
- **Eventos en tiempo real**: `zonix-realtime-events` § 3-8 (actualizar UI al recibir cambios).

