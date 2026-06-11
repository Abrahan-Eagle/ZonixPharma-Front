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

## Spec Kit (espejo — hub en Backend)

Specs SDD viven en **[../ZonixPharma-Backend/specs/](../ZonixPharma-Backend/specs/)**. Constitution: [../ZonixPharma-Backend/.specify/memory/constitution.md](../ZonixPharma-Backend/.specify/memory/constitution.md).

Skills proceso: `.cursor/skills/speckit-*`. Dominio: `.agents/skills/zonix-*` (stubs → Backend).

Guía: [../ZonixPharma-Backend/docs/zonix/SPEC_KIT_ZONIX.md](../ZonixPharma-Backend/docs/zonix/SPEC_KIT_ZONIX.md).

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
| **Archivos Dart (`lib/`)** | 203 |
| **Pantallas** | 89 |
| **Tests** | 227 passed (~1 skip) |
| **Última actualización** | 10 junio 2026 |

### Cambios recientes

- **10 jun 2026 — Remediación módulo commerce (auditoría 360° + multi-sede).**
  - `commerce_api_errors.dart` + rollout en 9 servicios; tab **Receta Rx** en órdenes; sin fake success en writes.
  - `CommerceContext`: `X-Commerce-Id` en panel; sync sede en lista/Ver/set-primary.
  - Brand commerce: `AppColors.*` en 22 pantallas; `Colors.transparent` residual eliminado.
  - Docs: [../ZonixPharma-Backend/docs/AUDIT_commerce_8fases_2026-06-10.md](../ZonixPharma-Backend/docs/AUDIT_commerce_8fases_2026-06-10.md).
- **10 jun 2026 — Remediación buyer orders (Rx post-checkout, lote 1).**
  - `order_detail_page`: CTA **Subir receta** cuando `pending_prescription_validation` sin `prescription_id`.
  - `order_service.cancelOrder`: exige `success == true` (sin falso positivo).
- **27 may 2026 — Spec Kit (SDD) espejo Cursor:** skills `speckit-*` en `.cursor/skills/`; hub de specs en repo Backend.
- **30 abr 2026 — Transformación Zonix Eats → Zonix Pharma (fork destructivo, MVP completo Rx).**
  - Branding: `MaterialApp.title = 'Zonix Pharma'`, `AppConfig.appName` por defecto `Zonix Pharma`, web manifest/title `Zonix Pharma`, canal FCM `zonix_pharma_fcm`, deep link `zonix://pharmacy/{id}`.
  - **Android (parche temporal):** `applicationId` / `namespace` = `com.zonix.eats` en `android/app/build.gradle` (Firebase/Google Sign-In compartido con proyecto Eats). **Objetivo:** `com.zonix.pharma` cuando la app esté registrada en consola con las mismas SHA.
  - **iOS:** `bundleId = com.zonix.pharma`. Firebase iOS (`GoogleService-Info.plist`) pendiente.
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
| `zonix-design-enforcer` | Grid 8pt, WCAG, tokens brand*, M3/HIG | [.agents/skills/zonix-design-enforcer/SKILL.md](.agents/skills/zonix-design-enforcer/SKILL.md) |
| `zonix-brand-ops` | Naming, tono pharma, 60-30-10 (stub → Backend) | [.agents/skills/zonix-brand-ops/SKILL.md](.agents/skills/zonix-brand-ops/SKILL.md) |
| `zonix-web-design` | Landing Blade/CSS (stub → Backend) | [.agents/skills/zonix-web-design/SKILL.md](.agents/skills/zonix-web-design/SKILL.md) |
| `context-updater` | Actualizar `docs/active_context.md` | [.agents/skills/context-updater/SKILL.md](.agents/skills/context-updater/SKILL.md) |
| `documentar-avances` | Proponer "Cambios recientes" | [.agents/skills/documentar-avances/SKILL.md](.agents/skills/documentar-avances/SKILL.md) |
| `zonix-startup-context` | Contexto canónico inversor (stub → Backend) | [.agents/skills/zonix-startup-context/SKILL.md](.agents/skills/zonix-startup-context/SKILL.md) |
| `zonix-investor-materials` | Data room / pack Lanzamiento (stub → Backend) | [.agents/skills/zonix-investor-materials/SKILL.md](.agents/skills/zonix-investor-materials/SKILL.md) |
| `zonix-lanzamiento-roles` | Roles pack inversor (stub → Backend) | [.agents/skills/zonix-lanzamiento-roles/SKILL.md](.agents/skills/zonix-lanzamiento-roles/SKILL.md) |
| `zonix-launch-piloto` | Plan piloto T+0→Day-D (stub → Backend) | [.agents/skills/zonix-launch-piloto/SKILL.md](.agents/skills/zonix-launch-piloto/SKILL.md) |
| `zonix-jarvis-subagents-map` | Subagents lente → skill canon (stub → Backend) | [.agents/skills/zonix-jarvis-subagents-map/SKILL.md](.agents/skills/zonix-jarvis-subagents-map/SKILL.md) |
| `zonix-legal-contracts-ve` | Checklist contratos VE (stub → Backend) | [.agents/skills/zonix-legal-contracts-ve/SKILL.md](.agents/skills/zonix-legal-contracts-ve/SKILL.md) |
| `zonix-founder-ops-index` | Índice CEO/CTO (stub → Backend) | [.agents/skills/zonix-founder-ops-index/SKILL.md](.agents/skills/zonix-founder-ops-index/SKILL.md) |
| `zonix-empresa-ve` | Constitución / SAFE / laboral VE (stub → Backend) | [.agents/skills/zonix-empresa-ve/SKILL.md](.agents/skills/zonix-empresa-ve/SKILL.md) |

> **Skills financieras completas** (`zonix-financial-model`, `zonix-fundraising-narrative`, `zonix-regulatory-ve`): solo en [ZonixPharma-Backend/.agents/skills/](../ZonixPharma-Backend/.agents/skills/).

---

## Auto-invoke Skills

| Acción | Skill |
| ------ | ----- |
| Crear/modificar pantallas o widgets | `flutter-expert` |
| Crear/modificar servicios | `flutter-expert` |
| Diseñar UI/UX Flutter | `zonix-ui-design` + `zonix-design-enforcer` + `ui-ux-pro-max` (secundaria) |
| Copy / naming / branding app | `zonix-brand-ops` (stub → Backend) |
| Onboarding (incluye pharmacist) | `zonix-onboarding` |
| Estados / flujo de órdenes | `zonix-order-lifecycle` |
| Implementar Pusher / FCM | `zonix-realtime-events` |
| Hacer git commit | `git-commit` |
| Cerrar sesión con cambios | `context-updater` |
| Finalizar tarea | `documentar-avances` |
| UI alineada a pack inversor / claims salud | `zonix-startup-context` + `zonix-lanzamiento-roles` + Backend `zonix-regulatory-ve` |
| Hitos piloto / calendario Day-D (solo planificación) | `zonix-launch-piloto` (stub → Backend) |
| Tarea multi-rol (subagent + skill canon) | `zonix-jarvis-subagents-map` (stub → Backend) |
| Nueva feature producto (spec en Backend hub) | Spec Kit `speckit-*` + `zonix-ui-design` + `zonix-design-enforcer` / `zonix-order-lifecycle` — ver Backend [SPEC_KIT_ZONIX.md](../ZonixPharma-Backend/docs/zonix/SPEC_KIT_ZONIX.md) |
| Revisar contrato / T&C farmacia (checklist) | `zonix-legal-contracts-ve` (stub → Backend) |
| Constitución / SAFE / textos legales app (checklist) | `zonix-empresa-ve` (stub → Backend) |

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
- **[../ZonixPharma-Backend/docs/Lanzamiento/README.md](../ZonixPharma-Backend/docs/Lanzamiento/README.md)** — pack inversor
- **[../ZonixPharma-Backend/docs/zonix/research_links.md](../ZonixPharma-Backend/docs/zonix/research_links.md)** — skills GitHub

---

**Última actualización:** 9 junio 2026
**Para instrucciones completas:** Ver `README.md`
