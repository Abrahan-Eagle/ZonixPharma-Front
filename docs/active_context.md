# Contexto activo de sesión — Zonix Pharma Frontend

> **Uso:** La IA debe leer este archivo al iniciar o retomar trabajo en el proyecto para recuperar el estado reciente sin depender de que el usuario lo pida.

---

## Última actualización de contexto

### Verificación local 10 mayo 2026

- **Backend** (`ZonixPharma-Backend`): detalle e histórico en [`../ZonixPharma-Backend/docs/active_context.md`](../ZonixPharma-Backend/docs/active_context.md). Pack comercial / inversor (base **USD 101k + Co-CEO**, narrativa y números alineados): [`../ZonixPharma-Backend/docs/Lanzamiento/README.md`](../ZonixPharma-Backend/docs/Lanzamiento/README.md).
- **Frontend** (`ZonixPharma-Front`): `flutter test` → **216 passed** (~1 skipped). Última corrida de verificación en esta fecha.
- **Repo:** `.gitignore` ignora `.env` / `.env.*` (excepto `.env.example`) para evitar commits accidentales de secretos.

---

### Entrega mayor 30 abril 2026

- **Fecha:** 30 abril 2026
- **Resumen:** **Transformación Zonix Eats → Zonix Pharma (fork destructivo, MVP completo Rx)** del frontend Flutter, espejo del backend (documentación de marca y planes en `../ZonixPharma-Backend/docs/`).
- **Áreas tocadas (frontend):**
  - Branding: `MaterialApp.title = 'Zonix Pharma'`, `AppConfig.appName` por defecto `Zonix Pharma`, `applicationId / namespace = com.zonix.pharma`, `bundleId = com.zonix.pharma`, web manifest/title `Zonix Pharma`, `userAgentPackageName` mapas, canal FCM `zonix_pharma_fcm`, deep link `zonix://pharmacy/{id}` (con compatibilidad legacy `zonix://restaurant/`).
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
