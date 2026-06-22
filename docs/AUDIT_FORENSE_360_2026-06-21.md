# AUDIT_FORENSE_360 — Espejo Front (Zonix Pharma)

**Fecha:** 21 junio 2026  
**Informe canónico completo:** [`../ZonixPharma-Backend/docs/AUDIT_FORENSE_360_2026-06-21.md`](../ZonixPharma-Backend/docs/AUDIT_FORENSE_360_2026-06-21.md)

---

## Baseline Front (21 jun 2026)

| Gate | Resultado |
|------|-----------|
| `flutter test` | **241 passed**, 1 skipped |
| `flutter analyze --no-fatal-infos` | **1 info** — `checkout_page.dart:285` deprecated `value` |

---

## Semáforo UI

| Área | Semáforo |
|------|----------|
| Rx UI (cart, checkout, order_detail, prescriptions) | **VERDE** |
| Helpers `*_api_errors` | **ÁMBAR** — 7/38 servicios HTTP |
| Brand `AppColors` vs `Colors.*` | **ROJO** — 87/92 pantallas |
| Legacy Eats copy/nombres | **ROJO** — módulo `restaurants/` |
| Plataforma Android/iOS | **ÁMBAR** — `com.zonix.eats`; sin Firebase iOS |

---

## Top acciones Front

1. Smoke UI Rx en dispositivo (ver Backend `SMOKE_RX_E2E.md`).
2. Helpers: `cart_api_errors`, `payment_api_errors`, `chat_api_errors`, `dispute_api_errors`.
3. Sprint brand buyer: `restaurants/*`, `products/*`, `cart/*`, `order_detail_page.dart`.
4. Migración Android → `com.zonix.pharma` + `GoogleService-Info.plist`.

Ver detalle, matriz API↔services y evidencia `ruta:línea` en el informe Backend.
