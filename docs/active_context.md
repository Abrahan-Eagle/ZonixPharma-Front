# Contexto activo de sesión — Zonix Pharma Frontend

> **Uso:** La IA debe leer este archivo al iniciar o retomar trabajo en el proyecto para recuperar el estado reciente sin depender de que el usuario lo pida.

---

## Última actualización de contexto

### P2 backlog lote 4 — 10 junio 2026

- Dashboard pharmacist cache en `PrescriptionService`; chat orden muestra **Farmacia**; util `formatRxCountdownLabel` testeada.
- **Verificación:** **237** tests (~1 skip).

### Cierre auditorías Rx/Orders — 10 junio 2026

- **Orders:** `order_api_errors.dart`; `OrderService` exige `success` en list/show/tracking/cancel.
- **Doc Backend:** `AUDIT_orders_2026-06-10.md`, `SMOKE_RX_E2E.md`.
- **Verificación:** `flutter test` **233** passed (~1 skip).

### Auditoría pharmacist lote 3 — 10 junio 2026

- **Hecho:** Buyer Rx en `PrescriptionService` exige `success == true` (list/upload/delete); onboarding MPPS parsea envelope + `pharmacistHttpErrorMessage`.
- **Doc Backend:** `docs/AUDIT_pharmacist_2026-06-10.md`.
- **Verificación:** `flutter analyze` OK; `flutter test` → **230 passed** (~1 skip).

- **Pendiente:** auditoría 360° módulo orders completa; smoke E2E Rx.

### Remediación módulo pharmacist (lote 2 — historial) — 10 junio 2026

- **Hecho:** `PrescriptionsHistoryPage` en tab Historial (shell level 5); filtros Todas/Aprobadas/Rechazadas/Expiradas; `PrescriptionService.loadHistoryForPharmacist`.
- **Backend (espejo):** endpoint `/api/pharmacist/prescriptions/history`.

### Remediación módulo pharmacist (lote 1) — 10 junio 2026

- **Hecho:** `pharmacist_api_errors.dart`; `PrescriptionService` exige `success`, carga detalle Rx autenticado; `ValidationDetailPage` refresca receta al abrir; dashboard usa mensajes API.
- **Backend (espejo):** throttle approve/reject; tests dashboard + licencia inválida.
- **Verificación:** `flutter test` → **230 passed** (~1 skip).

### Remediación buyer orders (lote 2) — 10 junio 2026

- **Hecho:** modelo `Order` con `expiresAt` / `requiresPrescription`; chip cuenta regresiva TTL Rx en `order_detail_page`; `getOrdersByDateRange` filtra en cliente (backend no soporta fechas).
- **Backend (espejo):** `OrderTrackingController` Pharma + Rx; test comando TTL recetas.
- **Verificación:** `flutter test` → **228 passed** (~1 skip); `flutter analyze` 0 issues.
- **Pendiente:** smoke manual Rx end-to-end (subir receta → validación farmacéutico → pago).

### Remediación buyer orders (lote 1) — 10 junio 2026

- **Front:** CTA **Subir receta** en `order_detail_page` (Rx sin receta); `order_service.cancelOrder` exige `success == true`.
- **Backend (espejo):** timeline tracking Rx; cancel 409; throttle cancel/pago.

### Remediación módulo Commerce + multi-sede — 10 junio 2026

- **Hecho:** `commerce_api_errors.dart` + rollout en 9 servicios; tab **Receta Rx** en órdenes; sin fake success en `updatePaymentData`/`createCommerce`. **`CommerceContext`**: persiste `active_commerce_id`, envía `X-Commerce-Id` en `commerce_*_service`. Sincroniza sede al cargar lista / Ver / set-primary. Push `dev` → `f24bf47`.
- **Docs auditoría (Backend):** [`../ZonixPharma-Backend/docs/AUDIT_commerce_8fases_2026-06-10.md`](../ZonixPharma-Backend/docs/AUDIT_commerce_8fases_2026-06-10.md).
- **Verificación:** `flutter analyze` 0 issues; `flutter test` → **227 passed** (~1 skip).
- **Smoke manual:** login commerce multi-sede → Mis Comercios → Ver sede B → panel productos/órdenes solo de B; Editar/set-primary cambia default.
- **Brand commerce:** pantallas `screens/commerce/*` ya usan `AppColors.*`; quedaban 3 `Colors.transparent` → `AppColors.transparent`.

### Verificación local 9 junio 2026

- **Backend** (`ZonixPharma-Backend`): `php artisan test --parallel` → **399 passed**. Detalle en [`../ZonixPharma-Backend/docs/active_context.md`](../ZonixPharma-Backend/docs/active_context.md).
- **Frontend** (`ZonixPharma-Front`): `flutter test` → **216 passed** (~1 skipped).
- **Android ID (real):** `applicationId` = `com.zonix.eats` (parche Firebase temporal). Objetivo: `com.zonix.pharma`. iOS: `com.zonix.pharma`.
- **Repo:** `.gitignore` ignora `.env` / `.env.*` (excepto `.env.example`).

---

### Entrega mayor 30 abril 2026

- **Fecha:** 30 abril 2026
- **Resumen:** **Transformación Zonix Eats → Zonix Pharma (fork destructivo, MVP completo Rx)** del frontend Flutter, espejo del backend (documentación de marca y planes en `../ZonixPharma-Backend/docs/`).
- **Áreas tocadas (frontend):**
  - Branding: `MaterialApp.title = 'Zonix Pharma'`, `AppConfig.appName` por defecto `Zonix Pharma`, web manifest/title `Zonix Pharma`, canal FCM `zonix_pharma_fcm`, deep link `zonix://pharmacy/{id}` (compat legacy `zonix://restaurant/`).
  - **Android (parche temporal):** `applicationId` / `namespace` = `com.zonix.eats` — ver `android/app/build.gradle`. Objetivo: `com.zonix.pharma`.
  - **iOS:** `bundleId = com.zonix.pharma`.
  - Paleta: `lib/features/utils/app_colors.dart` reescrito con tokens `brandNavy`, `brandTealDeep`, `brandTeal`, `brandMint`, `brandSurfaceLight`, `brandMutedGray`, `brandSurfaceDark`, `brandCtaAccent`. Aliases legacy de Eats mapeados a Pharma para no romper 70+ archivos.
  - Tema: `lib/features/utils/app_theme.dart` migrado a Material 3 con `ColorScheme` Pharma, primario navy, secundario teal, CTA teal. Plus Jakarta Sans.
  - Splash: `flutter_native_splash.yaml` con `#F5F7FA / #142033`.
  - Modelos:
    - `lib/models/product.dart` reescrito con campos farmacéuticos (active_ingredient, dosage_form, concentration, presentation, manufacturer, health_registry, barcode, atc_code, requires_prescription, prescription_type, controlled_substance, cold_chain). Quitados campos comida (cuisines, allergens, isVegan, isGlutenFree, etc.).
    - `lib/models/prescription.dart` (nuevo).
    - `lib/models/medicine_lot.dart` (nuevo).
    - `lib/models/cart_item.dart` extendido con flags Rx/cold_chain/active_ingredient/concentration/presentation.
    - `lib/models/restaurant.dart` conservado con `typedef Pharmacy = Restaurant` para no romper imports.
  - Servicios:
    - `lib/features/services/prescription_service.dart` (nuevo, registrado en `MultiProvider` de `lib/main.dart`).
    - `lib/features/services/cart_service.dart` con getters `requiresPrescription`, `prescriptionRequiredItems`, `coldChainRequired`.
  - Pantallas nuevas:
    - `lib/features/screens/prescriptions/prescription_upload_page.dart`
    - `lib/features/screens/prescriptions/my_prescriptions_page.dart`
    - `lib/features/screens/pharmacist/pharmacist_dashboard_page.dart`
    - `lib/features/screens/pharmacist/pending_validations_page.dart`
    - `lib/features/screens/pharmacist/validation_detail_page.dart`
  - Assets: `assets/onboarding/onboarding_eats*.png` renombrados a `onboarding_pharma*.png`. Imports en `pubspec.yaml`, `products_page.dart` y `onboarding_screen.dart` actualizados.
  - Tests añadidos: `test/features/utils/storefront_qr_pharmacy_test.dart`, `test/models/prescription_model_test.dart`, `test/models/medicine_lot_model_test.dart`. `test/models/product_model_test.dart` y `test/models/cart_item_test.dart` actualizados con campos Pharma.
- **Próximos pasos sugeridos:**
  1. `flutter pub get` (re-indexa nuevos archivos).
  2. `flutter analyze` para detectar usos de tokens legacy de Eats que aún no migraron a `brand*`.
  3. `flutter test` para confirmar que la suite sigue verde.
  4. **UI pendiente** (no entró por scope mínimo):
     - Banner "Requiere receta médica" en `cart_page.dart` y `checkout_page.dart`, conectado a `cartService.requiresPrescription`.
     - Badge "Requiere receta" en `product_detail_page.dart` y cards de `restaurants_page.dart`/`products_page.dart`.
     - Sección Pharma (principio activo, presentación, registro INHRR) en `product_detail_page.dart`.
     - Onboarding del rol `pharmacist` con datos colegiados (MPPS, licencia, foto del título).
     - Drawer / nav para que el rol `pharmacist` aterrice en `PharmacistDashboardPage` al iniciar sesión (`MainRouter`).
  5. Reemplazar logos `assets/images/logo_login.png`, `splash_logo*.png`, `onboarding_pharma*.png` con los entregables de la lámina de marca y regenerar app icon (`flutter pub run flutter_launcher_icons:main`).
  6. Build APK debug y smoke OTC + Rx.

### Documentos clave

- `../ZonixPharma-Backend/docs/BRAND_ZONIX_PHARMA.md`
- `../ZonixPharma-Backend/docs/PLAN_RX_VALIDATION.md`
- `../ZonixPharma-Backend/docs/PLAN_REGULATORIO_PHARMA_VE.md`
- `../ZonixPharma-Backend/docs/MIGRACION_EATS_PHARMA.md`

---

### Histórico (sesiones anteriores)

> El histórico Eats se conserva como referencia pero ya no aplica a este repo
> tras el fork destructivo. Para ver el histórico Eats consultar el repo
> original Zonix Eats.
