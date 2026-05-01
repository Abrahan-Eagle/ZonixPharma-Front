# Auditoría UI — Migración Zonix Eats → Zonix Pharma

> Fecha: 1 mayo 2026
> Alcance: `lib/features/screens/**` y `lib/features/widgets/**`
> Criterio: skill [`zonix-ui-design`](../.agents/skills/zonix-ui-design/SKILL.md) v3 (Pharma) + [`BRAND_ZONIX_PHARMA.md`](../../ZonixPharma-Backend/docs/BRAND_ZONIX_PHARMA.md)
> Metodología: `rg` sobre tokens prohibidos + revisión manual de layouts.

## 1. Resumen ejecutivo

| Métrica | Valor |
| ------- | ----- |
| Archivos con `Colors.*` literal | 76 en `screens/`, 1 en `widgets/` |
| Archivos con `Color(0xAARRGGBB)` literal | 5 |
| Archivos con copy legacy Eats (restaurante/cuisine/hamburger/pizza/eats) | 11 |
| Módulos totales auditados | 25 (`admin`, `affiliate`, `auth`, `cart`, `commerce`, `delivery`, `delivery_company`, `favorites`, `help`, `location`, `notifications`, `onboarding`, `orders`, `pharmacist`, `prescriptions`, `products`, `profile`, `restaurants`, `settings`) |
| Estado global | **MAJOR** — mayoría de pantallas usa aliases legacy o `Colors.*`; pocos `Color(0x…)` residuales; copy Eats concentrado en buyer/commerce. |

## 2. Estado PASS / MINOR / MAJOR / NEEDS REWORK por módulo

Leyenda:
- **PASS:** sin violaciones.
- **MINOR:** 1–2 usos de alias legacy o `Colors.*`, fácil fix.
- **MAJOR:** ≥5 usos de `Colors.*` o `Color(0x…)` o copy Eats significativo.
- **NEEDS REWORK:** ≥15 usos, layout o copy Eats estructural.

| Módulo | Archivos | Estado | Observaciones |
| ------ | -------- | ------ | ------------- |
| `products` | `products_page.dart`, `product_detail_page.dart` | MAJOR | 3 + 10 violaciones Colors.* ; copy "cocina/cuisine"; `Color(0x…)` en detail. Cards Rx sí tienen badge (ya corregido). |
| `cart` | `cart_page.dart`, `checkout_page.dart` | MAJOR | 2 + 14 Colors.* ; falta banner Rx/coldChain. |
| `orders` | `orders_page.dart`, `order_detail_page.dart`, `order_confirmation_page.dart`, `current_order_detail_page.dart`, `order_history_detail_page.dart`, `order_rating_page.dart`, `buyer_order_chat_page.dart`, `buyer_dispute_detail_page.dart`, `buyer_disputes_page.dart`, `delivery_detail_page.dart`, `receipt_pdf_builder.dart` | MAJOR | 55 en order_detail; `Color(0x…)` en order_rating; timeline `pending_prescription_validation` debe existir. |
| `restaurants` | `restaurants_page.dart`, `restaurant_details_page.dart`, `storefront_qr_scanner_page.dart` | NEEDS REWORK | 5+11+1 Colors.* ; copy "restaurante/cuisine" 30+12+2. Clase raíz se llama Restaurant por compat, pero UI debe decir "Farmacia". |
| `commerce` | `commerce_dashboard_page.dart`, `commerce_orders_page.dart`, `commerce_products_page.dart`, `commerce_reports_page.dart`, `commerce_list_page.dart`, `commerce_detail_page.dart`, `commerce_add_restaurant_page.dart` (rename pendiente), `commerce_share_qr_page.dart`, `commerce_zones_page.dart`, `commerce_delivery_zones_page.dart`, `commerce_delivery_zone_form_page.dart`, `commerce_chat_page.dart`, `commerce_chat_messages_page.dart`, `commerce_order_detail_page.dart`, `commerce_promotions_page.dart`, `commerce_promotion_form_page.dart`, `commerce_payment_methods_page.dart`, `commerce_payment_method_form_page.dart`, `payment_method_detail_page.dart`, `commerce_profile_page.dart`, `commerce_profile_edit_page.dart` | NEEDS REWORK | 170+ Colors.* combinados; `Color(0x…)` en dashboard, share_qr, chat_messages, orders; copy "restaurante" en 5 archivos. |
| `pharmacist` | `pharmacist_dashboard_page.dart`, `pending_validations_page.dart`, `validation_detail_page.dart` | MINOR / pendiente explorar | No aparecen en conteo → verificar manualmente (posible PASS si ya usan `AppColors.brand*`). |
| `prescriptions` | `prescription_upload_page.dart`, `my_prescriptions_page.dart` | MINOR / pendiente explorar | No aparecen en grep → verificar. |
| `delivery` | `delivery_orders_page.dart`, `delivery_order_detail_page.dart`, `delivery_routes_page.dart`, `delivery_earnings_page.dart`, `delivery_history_page.dart`, `incoming_order_dialog.dart`, `qr_scanner_page.dart` | MAJOR | 15+12+10+12+8+5+1 Colors.* ; sin `Color(0x…)` ni copy Eats. |
| `delivery_company` | `delivery_company_map_page.dart`, `delivery_company_orders_page.dart`, `delivery_company_agents_page.dart`, `delivery_company_earnings_page.dart`, `delivery_company_dashboard_page.dart`, `delivery_company_add_agent_page.dart` | MAJOR | 28+21+8+11+20+2 Colors.* . |
| `admin` | `admin_dashboard_page.dart`, `admin_users_page.dart`, `admin_orders_page.dart`, `admin_analytics_page.dart`, `admin_commerces_page.dart`, `admin_notifications_page.dart`, `admin_delivery_companies_page.dart`, `admin_delivery_config_page.dart`, `admin_disputes_page.dart` | MAJOR | 24+21+9+19+12+6+8+13+17 Colors.* ; sin `Color(0x…)` literal (ya tiene tokens custom para gradientes). |
| `auth` | `sign_in_screen.dart` | MAJOR | 6 Colors.* + 1 copy "Eats". |
| `onboarding` | `onboarding_screen.dart`, `client_onboarding_flow.dart`, `onboarding_page1.dart`, `onboarding_page2.dart`, `onboarding_page3.dart`, `_archive/*` | MAJOR | 14+22+6+11+10 Colors.* ; archivo `_archive/` deprecado, ignorar. |
| `settings` | `settings_page_2.dart`, `commerce_data_page.dart`, `commerce_schedule_page.dart`, `legal_info_page.dart` | MAJOR | 15+15+16+2 Colors.* + `Color(0x…)` en settings_page_2. |
| `help` | `help_and_faq_page.dart` | MAJOR | 21 Colors.* . |
| `location` | `location_search_page.dart` | MINOR | 2 Colors.* . |
| `notifications` | `notifications_page.dart` | MAJOR | 5 Colors.* . |
| `profile` | (revisar) | — | Pendiente. |
| `favorites` | (revisar) | — | Pendiente. |
| `affiliate` | (revisar) | — | Pendiente. |
| `account_deletion_page.dart` | — | MAJOR | 14 Colors.* . |

## 3. Violaciones `Color(0xAARRGGBB)` literal

Deben ir a tokens `AppColors.brand*` o a `app_theme.dart` si son específicos del tema.

| Archivo | Ocurrencias |
| ------- | ----------- |
| [`commerce/commerce_dashboard_page.dart`](../lib/features/screens/commerce/commerce_dashboard_page.dart) | 1 |
| [`commerce/commerce_share_qr_page.dart`](../lib/features/screens/commerce/commerce_share_qr_page.dart) | 1 |
| [`commerce/commerce_chat_messages_page.dart`](../lib/features/screens/commerce/commerce_chat_messages_page.dart) | 2 |
| [`orders/buyer_order_chat_page.dart`](../lib/features/screens/orders/buyer_order_chat_page.dart) | 2 |
| [`commerce/commerce_orders_page.dart`](../lib/features/screens/commerce/commerce_orders_page.dart) | 1 |

## 4. Copy legacy Eats

Reemplazar en UI (no en nombres de archivo internos si son `Restaurant` de compatibilidad, pero el texto que ve el usuario SÍ debe decir "farmacia/medicamento").

| Archivo | Ocurrencias | Acción |
| ------- | ----------- | ------ |
| [`restaurants/restaurants_page.dart`](../lib/features/screens/restaurants/restaurants_page.dart) | 30 | "restaurante" → "farmacia"; `cuisineDisplay` → `specialtyDisplay`. |
| [`restaurants/restaurant_details_page.dart`](../lib/features/screens/restaurants/restaurant_details_page.dart) | 12 | idem. |
| [`products/product_detail_page.dart`](../lib/features/screens/products/product_detail_page.dart) | 10 | "link a restaurante" → "link a farmacia". |
| [`commerce/commerce_list_page.dart`](../lib/features/screens/commerce/commerce_list_page.dart) | 5 | "Mis restaurantes" → "Mis farmacias". |
| [`commerce/commerce_add_restaurant_page.dart`](../lib/features/screens/commerce/commerce_add_restaurant_page.dart) | 5 | "Agregar restaurante" → "Agregar farmacia"; rename archivo opcional. |
| [`auth/sign_in_screen.dart`](../lib/features/screens/auth/sign_in_screen.dart) | 1 | "Zonix Eats" → "Zonix Pharma". |
| [`products/products_page.dart`](../lib/features/screens/products/products_page.dart) | 1 | `hintText: 'Buscar hamburguesas, pizza...'` → `'Buscar medicinas o farmacias'` (coincide con restaurants_page). |
| [`restaurants/storefront_qr_scanner_page.dart`](../lib/features/screens/restaurants/storefront_qr_scanner_page.dart) | 2 | "QR del restaurante" → "QR de la farmacia". |
| [`orders/order_rating_page.dart`](../lib/features/screens/orders/order_rating_page.dart) | 3 | "califica el restaurante" → "califica la farmacia". |
| [`settings/settings_page_2.dart`](../lib/features/screens/settings/settings_page_2.dart) | 1 | revisar contexto. |
| [`onboarding/onboarding_page2.dart`](../lib/features/screens/onboarding/onboarding_page2.dart) | 1 | revisar copy. |

## 5. Reglas farmacéuticas (cobertura actual)

| Regla | Pantalla | Estado |
| ----- | -------- | ------ |
| Badge "Receta" en card producto (buyer) | [`products_page.dart`](../lib/features/screens/products/products_page.dart) | OK |
| Badge "Receta" en detalle producto | [`product_detail_page.dart`](../lib/features/screens/products/product_detail_page.dart) | Verificar |
| Badge "Controlado" en card/detalle | Todas | **Falta** |
| Badge "Cadena de frío" en card/detalle | Todas | **Falta** |
| Banner Rx en carrito | [`cart_page.dart`](../lib/features/screens/cart/cart_page.dart) | **Falta** |
| Banner Rx en checkout | [`checkout_page.dart`](../lib/features/screens/cart/checkout_page.dart) | **Falta** |
| Advertencia coldChain en checkout | [`checkout_page.dart`](../lib/features/screens/cart/checkout_page.dart) | **Falta** |
| Timeline `pending_prescription_validation` | [`order_detail_page.dart`](../lib/features/screens/orders/order_detail_page.dart) | Verificar |
| Botón "Subir receta" vinculando a `PrescriptionUploadPage` | [`cart_page.dart`](../lib/features/screens/cart/cart_page.dart) / [`checkout_page.dart`](../lib/features/screens/cart/checkout_page.dart) | **Falta** |

## 6. Overflows / layout conocidos

| Pantalla | Issue | Estado |
| -------- | ----- | ------ |
| `products_page.dart` grid celda | `RenderFlex` ~9–12 px overflow | Corregido (`childAspectRatio 0.62` + Expanded rating + Column(end) precio). |
| `cart_page.dart`, `checkout_page.dart` | Revisar con banner Rx nuevo | Pendiente validar tras fase 2. |
| `admin_dashboard_page.dart` | `childAspectRatio 0.68` con FittedBox | Revisar contraste/paleta. |

## 7. Accesibilidad (dark)

Pendiente ejecutar checklist §5 de [`BRAND_ZONIX_PHARMA.md`](../../ZonixPharma-Backend/docs/BRAND_ZONIX_PHARMA.md):
- Texto sobre `#142033` ≥ 4.5:1.
- `brandTeal #56C7B8` sobre `#142033` (iconos/CTA) ≥ 3:1 → validar, en el límite.
- `brandMint #A8DCCB` como texto sobre `#142033` → verificar por tamaño.
- `brandCtaAccent #F2A65A` con texto navy/blanco → validar por botón.

Sugerencia: golden test en `checkout_page`, `prescription_upload_page`, `pharmacist_dashboard_page` + `cart_page` para light y dark.

## 8. Plan de correctivos (orden propuesto)

### P0 (marca/función crítica) — Fase 2.a
1. [`products_page.dart`](../lib/features/screens/products/products_page.dart): hint search + rating/precio tokens.
2. [`cart_page.dart`](../lib/features/screens/cart/cart_page.dart): banner Rx + coldChain + CTA "Subir receta".
3. [`checkout_page.dart`](../lib/features/screens/cart/checkout_page.dart): banner Rx + coldChain + bloqueo botón "Pagar" sin receta aprobada.
4. [`orders/order_detail_page.dart`](../lib/features/screens/orders/order_detail_page.dart): timeline con `pending_prescription_validation`.
5. `Color(0x…)` → tokens en los 5 archivos de §3.

### P1 (roles operativos) — Fase 2.b
6. [`pharmacist/*`](../lib/features/screens/pharmacist/) — alinear a skill §4 "Pharmacist".
7. [`commerce/*`](../lib/features/screens/commerce/) — migración masiva Colors.* + copy; renombrar título "Mis restaurantes" → "Mis farmacias".
8. [`admin/*`](../lib/features/screens/admin/) — tokens en cards métricas (el dashboard ya tiene tokens custom para gradientes, completar).

### P2 (auth/onboarding/config) — Fase 2.c
9. [`auth/sign_in_screen.dart`](../lib/features/screens/auth/sign_in_screen.dart) — copy + botón Google con paleta Pharma.
10. [`onboarding/*`](../lib/features/screens/onboarding/) — carousel Pharma, selector de rol incluye `pharmacist`.
11. [`settings/*`](../lib/features/screens/settings/), [`help/help_and_faq_page.dart`](../lib/features/screens/help/help_and_faq_page.dart), [`notifications/notifications_page.dart`](../lib/features/screens/notifications/notifications_page.dart), [`location/location_search_page.dart`](../lib/features/screens/location/location_search_page.dart).
12. [`delivery/*`](../lib/features/screens/delivery/), [`delivery_company/*`](../lib/features/screens/delivery_company/).
13. [`widgets/buyer_shell.dart`](../lib/features/widgets/buyer_shell.dart) — 9 Colors.* .

### Cierre
14. Eliminar aliases legacy de [`AppColors`](../lib/features/utils/app_colors.dart) cuando grep de aliases retorne 0 usos.
15. Añadir `custom_lint` o regla CI que prohíba `Colors\.(red|blue|…)` en `lib/features/screens/**`.

## 9. Notas

- La clase Dart `Restaurant` (`lib/models/restaurant.dart`) se mantiene como alias por compatibilidad; la UI solo debe reemplazar **copy visible al usuario**, no identificadores de código ni rutas internas.
- El archivo `commerce_add_restaurant_page.dart` puede renombrarse a `commerce_add_pharmacy_page.dart` en fase de cierre; si se renombra, actualizar imports.
- `_archive/*` en onboarding queda fuera del alcance (código desuso).
