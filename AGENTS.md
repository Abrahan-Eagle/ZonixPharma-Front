# AGENTS.md - Zonix Pharma Frontend (Flutter App)

> Instrucciones para AI coding agents trabajando en el frontend móvil de Zonix Pharma.
> Para documentación detallada, ver `README.md`.

## Contexto de sesión

**Al iniciar o retomar trabajo:** leer [docs/active_context.md](docs/active_context.md) si existe.

---

## Brand y experiencia (fuente canónica)

**Nombre en UI:** Zonix Pharma. **Producto:** marketplace farmacéutico digital del ecosistema Zonix (vertical **Pharma**, no Eats).

**Identidad visual:** símbolo Z geométrico + wordmark + PHARMA en caps teal; **paleta, tipografía, do/don’t, grid de iconos (24px), modo oscuro y checklist de contraste** en el repo Backend: **[docs/BRAND_ZONIX_PHARMA.md](../ZonixPharma-Backend/docs/BRAND_ZONIX_PHARMA.md)**.

Implementación en código Flutter: `lib/features/utils/app_colors.dart`, `lib/features/utils/app_theme.dart`. `.cursorrules` remite aquí — no duplicar el párrafo largo de marca.

---

## Project Overview

| Métrica | Valor |
| ------------------------ | -------------------------------------- |
| **Producto** | Zonix Pharma — marketplace farmacéutico VE |
| **Framework** | Flutter >=3.5.0 <4.0.0 |
| **Lenguaje** | Dart 3.5.0+ |
| **Versión** | 1.0.0 |
| **Estado** | Migración Eats → Pharma (fork destructivo) en progreso |
| **Plataformas** | Android + iOS |
| **Última actualización** | 30 abril 2026 |

### Cambios recientes

- **30 abr 2026 — Transformación Zonix Eats → Zonix Pharma (fork destructivo, MVP completo Rx).**
  - Branding: `MaterialApp.title = 'Zonix Pharma'`, `AppConfig.appName` por defecto `Zonix Pharma`, `applicationId = com.zonix.pharma` (Android), `bundleId = com.zonix.pharma` (iOS), web manifest/title `Zonix Pharma`, canal FCM `zonix_pharma_fcm`, deep link `zonix://pharmacy/{id}`.
  - Paleta Pharma fría en `lib/features/utils/app_colors.dart` (tokens `brand*`) + tema light/dark Pharma en `app_theme.dart` (Plus Jakarta Sans, primario navy, secundario teal, CTA teal). Splash actualizado a `#F5F7FA / #142033`.
  - Modelos: `Product` extendido con campos farmacéuticos (principio activo, presentación, registro INHRR, requires_prescription, controlled_substance, cold_chain, etc.). Nuevos: `Prescription`, `MedicineLot`. `CartItem` con flags Rx/cold_chain. Modelo `Restaurant` mantenido como alias `Pharmacy` para compatibilidad.
  - Servicio nuevo: `PrescriptionService` (registrado en `MultiProvider` de `main.dart`). Pantallas nuevas: `PrescriptionUploadPage`, `MyPrescriptionsPage`, `PharmacistDashboardPage`, `PendingValidationsPage`, `ValidationDetailPage`.
  - Rol nuevo `pharmacist` (farmacéutico colegiado); su flujo se documenta en backend `docs/PLAN_RX_VALIDATION.md`.

---

## Modelo de datos (sincronizado con backend Pharma)

### `Product` (medicamento / producto de farmacia)

Campos clave:
- `requiresPrescription`, `prescriptionType` (`common` / `retained` / `special`).
- `controlledSubstance`, `coldChain`.
- `activeIngredient`, `dosageForm`, `concentration`, `presentation`, `manufacturer`, `healthRegistry` (INHRR), `barcode`, `atcCode`.

### `Prescription`

- Estados: `pending_validation`, `approved`, `rejected`, `expired`.
- Tipos: `common`, `retained`, `special`.
- Sube vía `PrescriptionUploadPage` (multipart con foto/PDF).
- Backend: `/api/buyer/prescriptions` (buyer), `/api/pharmacist/prescriptions/*` (pharmacist).

### `Cart`

- `cartService.requiresPrescription`: indica si hay items Rx.
- `cartService.prescriptionRequiredItems`: lista de items Rx.
- `cartService.coldChainRequired`: indica si hay items cadena de frío.
- UI debe mostrar banner "Requiere receta médica" en `cart_page` y `checkout_page` cuando `requiresPrescription` es true.

### `Order`

- Estado nuevo: `pending_prescription_validation` (entre creación y `pending_payment`).
- Mostrar timeline ampliado en `order_detail_page` cuando `requires_prescription`.

---

## Setup Commands

```bash
flutter pub get
cp .env.example .env
flutter run
flutter test
flutter analyze
```

### Build

```bash
flutter build apk
flutter build appbundle
flutter build ios
```

---

## CI y quality gates

| Paso | Comando / ubicación |
| ---- | ------------------- |
| Análisis estático | `flutter analyze --no-fatal-infos` en CI (falla ante error/warning; ver comentario en el workflow). |
| Tests | `flutter test`. |
| Workflow GitHub Actions | [`.github/workflows/ci.yml`](.github/workflows/ci.yml): se ejecuta en push/PR a `main`, `develop`, `dev` si el archivo existe en el remoto. |

**Umbral recomendado:** mismo criterio que Backend `AGENTS.md` — nuevas pantallas bajo `lib/features/screens/**` sin violaciones nuevas de marca (colores vía `AppColors` / tema). Opcional futuro: regla `custom_lint` o script que rechace `Colors.` en ese árbol.

---

## Architecture

### Estructura `lib/`

```
lib/
├── config/
│ └── app_config.dart                 # apiUrl, deep link zonix://pharmacy/{id}
├── features/
│ ├── screens/
│ │ ├── auth/
│ │ ├── products/                     # Catálogo (medicinas)
│ │ ├── cart/
│ │ ├── orders/
│ │ ├── restaurants/                  # Listado de farmacias (alias legacy; copy "Farmacia")
│ │ ├── commerce/                     # Panel de farmacia (commerce role)
│ │ ├── pharmacist/                   # NUEVO: dashboard, pendientes, validación
│ │ ├── prescriptions/                # NUEVO: subir receta, mis recetas
│ │ ├── delivery/
│ │ ├── delivery_company/
│ │ ├── admin/
│ │ ├── notifications/
│ │ ├── settings/
│ │ └── onboarding/
│ ├── services/
│ │ ├── cart_service.dart             # con flags requiresPrescription, coldChainRequired
│ │ ├── order_service.dart
│ │ ├── prescription_service.dart     # NUEVO
│ │ ├── pusher_service.dart
│ │ └── …
│ └── DomainProfiles/                 # Profile (1:1 user), addresses, documents, phones
├── helpers/
│ └── auth_helper.dart
├── models/
│ ├── product.dart                    # con campos farmacéuticos
│ ├── prescription.dart               # NUEVO
│ ├── medicine_lot.dart               # NUEVO
│ ├── cart_item.dart                  # con flags Rx
│ ├── order.dart
│ ├── commerce.dart
│ └── restaurant.dart                 # typedef Pharmacy = Restaurant (legacy)
├── widgets/
└── main.dart                         # MaterialApp(title: 'Zonix Pharma')
```

### Patrón

```
User Interaction (Screen)
   ↓
Provider / Service (extends ChangeNotifier)
   ↓
HTTP usando AuthHelper.getAuthHeaders()
   ↓
Backend Laravel (Zonix Pharma)
   ↓
notifyListeners() → Consumer<Service>
```

---

## Available Skills

| Skill | Ruta |
| ----- | ---- |
| `flutter-expert` | [.agents/skills/flutter-expert/SKILL.md](.agents/skills/flutter-expert/SKILL.md) |
| `clean-architecture` | [.agents/skills/clean-architecture/SKILL.md](.agents/skills/clean-architecture/SKILL.md) |
| `mobile-developer` | [.agents/skills/mobile-developer/SKILL.md](.agents/skills/mobile-developer/SKILL.md) |
| `ui-ux-pro-max` | [.agents/skills/ui-ux-pro-max/SKILL.md](.agents/skills/ui-ux-pro-max/SKILL.md) |
| `responsive-design` | [.agents/skills/responsive-design/SKILL.md](.agents/skills/responsive-design/SKILL.md) |
| `systematic-debugging` | [.agents/skills/systematic-debugging/SKILL.md](.agents/skills/systematic-debugging/SKILL.md) |
| `test-driven-development` | [.agents/skills/test-driven-development/SKILL.md](.agents/skills/test-driven-development/SKILL.md) |
| `flutter-animations` | [.agents/skills/flutter-animations/SKILL.md](.agents/skills/flutter-animations/SKILL.md) |
| `git-commit` | [.agents/skills/git-commit/SKILL.md](.agents/skills/git-commit/SKILL.md) |

### Custom (Zonix)

| Skill | Descripción | Ruta |
| ----- | ----------- | ---- |
| `zonix-onboarding` | Onboarding por rol (incluye pharmacist) | [.agents/skills/zonix-onboarding/SKILL.md](.agents/skills/zonix-onboarding/SKILL.md) |
| `zonix-order-lifecycle` | Estados de orden incluyendo `pending_prescription_validation` | [.agents/skills/zonix-order-lifecycle/SKILL.md](.agents/skills/zonix-order-lifecycle/SKILL.md) |
| `zonix-realtime-events` | Pusher, FCM, eventos | [.agents/skills/zonix-realtime-events/SKILL.md](.agents/skills/zonix-realtime-events/SKILL.md) |
| `zonix-ui-design` | Paleta Pharma, cards, layouts | [.agents/skills/zonix-ui-design/SKILL.md](.agents/skills/zonix-ui-design/SKILL.md) |
| `context-updater` | Actualizar `docs/active_context.md` | [.agents/skills/context-updater/SKILL.md](.agents/skills/context-updater/SKILL.md) |
| `documentar-avances` | Proponer "Cambios recientes" | [.agents/skills/documentar-avances/SKILL.md](.agents/skills/documentar-avances/SKILL.md) |

---

## Auto-invoke Skills

| Acción | Skill |
| ------ | ----- |
| Crear/modificar pantallas o widgets | `flutter-expert` |
| Crear/modificar servicios | `flutter-expert` |
| Diseñar UI/UX | `ui-ux-pro-max` + `zonix-ui-design` |
| Onboarding (incluye pharmacist) | `zonix-onboarding` |
| Estados / flujo de órdenes | `zonix-order-lifecycle` |
| Implementar Pusher / FCM | `zonix-realtime-events` |
| Hacer git commit | `git-commit` |
| Cerrar sesión con cambios | `context-updater` |
| Finalizar tarea | `documentar-avances` |

---

## Reglas Pharma específicas

### Productos Rx en cards y detalle

```dart
if (product.requiresPrescription)
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.brandTealDeep,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Text('Requiere receta',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
  )
```

### Carrito con Rx

`cart_page` y `checkout_page` deben:
1. Mostrar banner si `cartService.requiresPrescription`.
2. Listar items Rx con `cartService.prescriptionRequiredItems`.
3. Bloquear el botón "Pagar" hasta que el pedido tenga receta válida (estado `pending_payment`, no `pending_prescription_validation`).
4. Llevar a `PrescriptionUploadPage(orderId: ...)` para subir receta.

### Cadena de frío

Mostrar advertencia en checkout si `cartService.coldChainRequired`. Restringir UI de delivery sin equipo.

---

## Documentos clave (Pharma)

- **[../ZonixPharma-Backend/docs/BRAND_ZONIX_PHARMA.md](../ZonixPharma-Backend/docs/BRAND_ZONIX_PHARMA.md)**
- **[../ZonixPharma-Backend/docs/PLAN_RX_VALIDATION.md](../ZonixPharma-Backend/docs/PLAN_RX_VALIDATION.md)**
- **[../ZonixPharma-Backend/docs/PLAN_REGULATORIO_PHARMA_VE.md](../ZonixPharma-Backend/docs/PLAN_REGULATORIO_PHARMA_VE.md)**
- **[../ZonixPharma-Backend/docs/MIGRACION_EATS_PHARMA.md](../ZonixPharma-Backend/docs/MIGRACION_EATS_PHARMA.md)**

---

**Última actualización:** 30 abril 2026
**Para instrucciones completas:** Ver `README.md`
