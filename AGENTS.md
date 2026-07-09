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

Skills proceso: `~/.cursor/skills/speckit-*` (global) + `.agents/skills/speckit-git-*` (local). Dominio: `.agents/skills/zonix-*` (stubs → Backend).

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
- **10 jun 2026 — Remediación módulo pharmacist (lote 2 — historial).**
  - Tab **Historial** → `PrescriptionsHistoryPage` con filtros por estado.
- **10 jun 2026 — Remediación módulo pharmacist (lote 1).**
  - `pharmacist_api_errors.dart`; `PrescriptionService` con `success` + detalle Rx; refresh en `ValidationDetailPage`.
- **10 jun 2026 — Remediación buyer orders (Rx post-checkout, lote 2).**
  - `Order`: `expiresAt`, `requiresPrescription`, chip TTL en detalle Rx.
  - `commerce_order_service.getOrdersByDateRange`: filtro client-side.
  - Verificación: `flutter test` → **228 passed**.
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

## Panel de Expertos JARVIS (siempre activo)

JARVIS opera como agencia de desarrollo completa. Declarar roles: `> Roles: frontend (Flutter) + UX`. Roster global: `jarvis-experts`. Routing dominio: `zonix-jarvis-subagents-map` (Backend).

---

## Skills — Capas y sync global

**Precedencia UI:** `ui-router` → `zonix-ui-design` → `ui-ux-pro-max` (ver OVERLAY).

Tras `git pull` en jarvis-skills-library: `./scripts/sync-global-skills-from-library.sh` + `./scripts/check-global-skills-sync.sh`. Ver `MAINTENANCE_SKILLS.md`.

---

## Available Skills

Todos los skills se auto-generan con `python3 .agents/skills/sync.sh`.

<!-- SKILLS-START -->
| Skill | Descripción | Ruta |
|-------|-------------|------|
| `agent-loop-engineering` | Diseño de loops de agente concisos, reducidos y controlados: anatomía estímulo→iteración→stop, cuándo loop vs prompt, tipos de loop y mapeo a skills JARVIS. | [.agents/skills/agent-loop-engineering/SKILL.md](.agents/skills/agent-loop-engineering/SKILL.md) |
| `backlog-triage-ops` | Triage de backlog GitHub: auditar issues/PRs abiertos, clasificar disposición (merge, request-changes, close, needs-design), priorizar y generar reporte accionable. | [.agents/skills/backlog-triage-ops/SKILL.md](.agents/skills/backlog-triage-ops/SKILL.md) |
| `brainstorming-ops` | OBLIGATORIO antes de tareas complejas en proyecto activo: pantallas, providers, navegación, flujos KYC/onboarding. Propone alternativas y obtiene aprobación antes de codificar. | [.agents/skills/brainstorming-ops/SKILL.md](.agents/skills/brainstorming-ops/SKILL.md) |
| `branch-pr-ops` | Workflow branch + PR: naming conventional, checklist pre-PR, issue linking, presupuesto review, gh integration. Adaptable al AGENTS.md del repo. | [.agents/skills/branch-pr-ops/SKILL.md](.agents/skills/branch-pr-ops/SKILL.md) |
| `chained-pr-ops` | Divide PRs grandes en cadenas reviewables (stacked o feature-branch chain): regla 400 líneas, diagrama de dependencias, integración gh. | [.agents/skills/chained-pr-ops/SKILL.md](.agents/skills/chained-pr-ops/SKILL.md) |
| `clean-architecture` | Clean Architecture, SOLID principles, dependency injection, separation of concerns. | [.agents/skills/clean-architecture/SKILL.md](.agents/skills/clean-architecture/SKILL.md) |
| `code-review-playbook` | Use this skill when conducting or improving code reviews. Provides structured review processes, conventional comments patterns, language-specific checklists, and feedback templates. Use when reviewing PRs or standardizing review practices. | [.agents/skills/code-review-playbook/SKILL.md](.agents/skills/code-review-playbook/SKILL.md) |
| `cognitive-doc-design-ops` | Diseñar docs con baja carga cognitiva: lead with answer, progressive disclosure, checklists para review. | [.agents/skills/cognitive-doc-design-ops/SKILL.md](.agents/skills/cognitive-doc-design-ops/SKILL.md) |
| `comment-writer-ops` | Redactar comentarios de colaboración cálidos y directos: PR, issues, reviews, Slack. | [.agents/skills/comment-writer-ops/SKILL.md](.agents/skills/comment-writer-ops/SKILL.md) |
| `context-updater` | Actualizar el contexto de sesión para que la IA "recuerde" entre sesiones. Resumir cambios relevantes en docs/active_context.md al cerrar o finalizar una sesión de trabajo significativa. | [.agents/skills/context-updater/SKILL.md](.agents/skills/context-updater/SKILL.md) |
| `deep-interview-ops` | Entrevista socrática antes de tareas ambiguas en proyecto activo. Gate claridad mínima 3.5/5. | [.agents/skills/deep-interview-ops/SKILL.md](.agents/skills/deep-interview-ops/SKILL.md) |
| `design-md` | Analyze Stitch projects and synthesize a semantic design system into DESIGN.md files | [.agents/skills/design-md/SKILL.md](.agents/skills/design-md/SKILL.md) |
| `docs-alignment-ops` | Alinear documentación con código: docs describen comportamiento actual, mismo PR que el cambio, ejemplos verificables. | [.agents/skills/docs-alignment-ops/SKILL.md](.agents/skills/docs-alignment-ops/SKILL.md) |
| `documentar-avances` | Al finalizar una tarea relevante, proponer el párrafo para "Cambios recientes" en AGENTS.md y/o README. El usuario aprueba antes de que se escriba en el repo. | [.agents/skills/documentar-avances/SKILL.md](.agents/skills/documentar-avances/SKILL.md) |
| `doubt-driven-development` | Revisión adversarial in-flight de decisiones no triviales: CLAIM → EXTRACT → DOUBT → RECONCILE → STOP. | [.agents/skills/doubt-driven-development/SKILL.md](.agents/skills/doubt-driven-development/SKILL.md) |
| `engram-memory-protocol` | Disciplina de memoria persistente con Engram MCP: mem_save, mem_search, mem_context, cierre de sesión y recuperación post-compactación. | [.agents/skills/engram-memory-protocol/SKILL.md](.agents/skills/engram-memory-protocol/SKILL.md) |
| `engram-router` | Orquesta memoria persistente Engram (MCP) vs context-updater/handoff/active_context JARVIS. | [.agents/skills/engram-router/SKILL.md](.agents/skills/engram-router/SKILL.md) |
| `enhance-prompt` | Transforms vague UI ideas into polished, Stitch-optimized prompts. Enhances specificity, adds UI/UX keywords, injects design system context, and structures output for better generation results. | [.agents/skills/enhance-prompt/SKILL.md](.agents/skills/enhance-prompt/SKILL.md) |
| `executing-plans` | Ejecutar plan Flutter paso a paso. | [.agents/skills/executing-plans/SKILL.md](.agents/skills/executing-plans/SKILL.md) |
| `fan-out-synthesize-ops` | Orquestación por defecto JARVIS: Map-Reduce agentico / Fan-out-and-synthesize — N subagentes en paralelo recaudan contexto → sesión principal (orquestador) sintetiza → writer único aplica → verify. | [.agents/skills/fan-out-synthesize-ops/SKILL.md](.agents/skills/fan-out-synthesize-ops/SKILL.md) |
| `finishing-a-development-branch` | Cerrar feature Flutter: analyze + test, opciones merge/PR. | [.agents/skills/finishing-a-development-branch/SKILL.md](.agents/skills/finishing-a-development-branch/SKILL.md) |
| `flutter-animations` | Comprehensive guide for implementing animations in Flutter. Use when adding motion and visual effects to Flutter apps: implicit animations (AnimatedContainer, AnimatedOpacity, TweenAnimationBuilder), explicit animations (AnimationController, Tween, AnimatedWidget/AnimatedBuilder), hero animations (shared element transitions), staggered animations (sequential/overlapping), and physics-based animations. Includes workflow for choosing the right animation type, implementation patterns, and best practices for performance and user experience. | [.agents/skills/flutter-animations/SKILL.md](.agents/skills/flutter-animations/SKILL.md) |
| `flutter-expert` | Flutter advanced patterns, widgets, lifecycle, state management, performance. | [.agents/skills/flutter-expert/SKILL.md](.agents/skills/flutter-expert/SKILL.md) |
| `git-commit` | Execute git commit with conventional commit message analysis, intelligent staging, and message generation. Use when user asks to commit changes, create a git commit, or mentions "/commit". Supports: (1) Auto-detecting type and scope from changes, (2) Generating conventional commit messages from diff, (3) Interactive commit with optional type/scope/description overrides, (4) Intelligent file staging for logical grouping | [.agents/skills/git-commit/SKILL.md](.agents/skills/git-commit/SKILL.md) |
| `git-guardrails-ops` | Protección git: bloquea push a main, advierte en dev, exige confirmación antes de comandos destructivos. | [.agents/skills/git-guardrails-ops/SKILL.md](.agents/skills/git-guardrails-ops/SKILL.md) |
| `github-code-review` | Comprehensive GitHub code review with AI-powered swarm coordination | [.agents/skills/github-code-review/SKILL.md](.agents/skills/github-code-review/SKILL.md) |
| `handoff` | Compactar la sesion actual en un documento de traspaso para continuar en otro agente o chat. Complementa session-learner-ops (cierre de modulo) y active_context.md. | [.agents/skills/handoff/SKILL.md](.agents/skills/handoff/SKILL.md) |
| `human-in-the-loop-ops` | Gobernanza humana en bucles agénticos: HITL/HOTL/automation-bounded, umbrales de confianza, condiciones de terminación y escalamiento. | [.agents/skills/human-in-the-loop-ops/SKILL.md](.agents/skills/human-in-the-loop-ops/SKILL.md) |
| **`jarvis-core`** | **Protocolo base del sistema JARVIS para cualquier proyecto. Define honestidad, foco de negocio y flujo de trabajo modular.** | [.agents/skills/jarvis-core/SKILL.md](.agents/skills/jarvis-core/SKILL.md) |
| `jarvis-experts` | Panel de Expertos JARVIS (agencia de desarrollo virtual). Define roster de roles, criterios de activación, combinaciones recomendadas y plantilla de declaración. | [.agents/skills/jarvis-experts/SKILL.md](.agents/skills/jarvis-experts/SKILL.md) |
| `mobile-developer` | Mobile development patterns, platform-specific code, deep linking, push notifications. | [.agents/skills/mobile-developer/SKILL.md](.agents/skills/mobile-developer/SKILL.md) |
| `notebooklm-router` | Orquesta consulta RAG a Google NotebookLM (corpus grande/duradero con citas) vía MCP `notebooklm-mcp` vs subida directa al contexto y vs Engram (memoria cross-session). | [.agents/skills/notebooklm-router/SKILL.md](.agents/skills/notebooklm-router/SKILL.md) |
| `parallel-judge-ops` | Patrón "día del juicio": 2+ jueces adversariales en paralelo e independientes → orquestador valida real vs ruido → subagente aplica fixes → itera hasta sin hallazgos o max iterations. | [.agents/skills/parallel-judge-ops/SKILL.md](.agents/skills/parallel-judge-ops/SKILL.md) |
| `playwright-skill` | Complete browser automation with Playwright. Auto-detects dev servers, writes clean test scripts to /tmp. Test pages, fill forms, take screenshots, check responsive design, validate UX, test login flows, check links, automate any browser task. Use when user wants to test websites, automate browser interactions, validate web functionality, or perform any browser-based testing. | [.agents/skills/playwright-skill/SKILL.md](.agents/skills/playwright-skill/SKILL.md) |
| `qa-testing-playwright` | E2E web testing with Playwright. Use when writing tests, debugging flakes, or setting up CI with selectors, sharding, and network mocking. | [.agents/skills/qa-testing-playwright/SKILL.md](.agents/skills/qa-testing-playwright/SKILL.md) |
| `react:components` | Converts Stitch designs into modular Vite and React components using system-level networking and AST-based validation. | [.agents/skills/react-components/SKILL.md](.agents/skills/react-components/SKILL.md) |
| `receiving-code-review` | Recibir feedback de review UI/código con verificación. | [.agents/skills/receiving-code-review/SKILL.md](.agents/skills/receiving-code-review/SKILL.md) |
| `remotion` | Generate walkthrough videos from Stitch projects using Remotion with smooth transitions, zooming, and text overlays | [.agents/skills/remotion/SKILL.md](.agents/skills/remotion/SKILL.md) |
| `requesting-code-review` | Code review antes de merge. | [.agents/skills/requesting-code-review/SKILL.md](.agents/skills/requesting-code-review/SKILL.md) |
| `responsive-design` | Implement modern responsive layouts using container queries, fluid typography, CSS Grid, and mobile-first breakpoint strategies. Use when building adaptive interfaces, implementing fluid layouts, or creating component-level responsive behavior. | [.agents/skills/responsive-design/SKILL.md](.agents/skills/responsive-design/SKILL.md) |
| `session-learner-ops` | Tras cerrar módulo UI: patrones en docs/active_context.md y walkthrough. | [.agents/skills/session-learner-ops/SKILL.md](.agents/skills/session-learner-ops/SKILL.md) |
| `shadcn-ui` | Expert guidance for integrating and building applications with shadcn/ui components, including component discovery, installation, customization, and best practices. | [.agents/skills/shadcn-ui/SKILL.md](.agents/skills/shadcn-ui/SKILL.md) |
| `skill-creator` | Guide for creating effective skills. This skill should be used when users want to create a new skill (or update an existing skill) that extends Claude's capabilities with specialized knowledge, workflows, or tool integrations. | [.agents/skills/skill-creator/SKILL.md](.agents/skills/skill-creator/SKILL.md) |
| `speckit-git-commit` | Auto-commit changes after a Spec Kit command completes | [.agents/skills/speckit-git-commit/SKILL.md](.agents/skills/speckit-git-commit/SKILL.md) |
| `speckit-git-feature` | Create a feature branch with sequential or timestamp numbering | [.agents/skills/speckit-git-feature/SKILL.md](.agents/skills/speckit-git-feature/SKILL.md) |
| `speckit-git-initialize` | Initialize a Git repository with an initial commit | [.agents/skills/speckit-git-initialize/SKILL.md](.agents/skills/speckit-git-initialize/SKILL.md) |
| `speckit-git-remote` | Detect Git remote URL for GitHub integration | [.agents/skills/speckit-git-remote/SKILL.md](.agents/skills/speckit-git-remote/SKILL.md) |
| `speckit-git-validate` | Validate current branch follows feature branch naming conventions | [.agents/skills/speckit-git-validate/SKILL.md](.agents/skills/speckit-git-validate/SKILL.md) |
| `stitch-loop` | Teaches agents to iteratively build websites using Stitch with an autonomous baton-passing loop pattern | [.agents/skills/stitch-loop/SKILL.md](.agents/skills/stitch-loop/SKILL.md) |
| `structured-commits-ops` | Commits con trailers de decisión en proyecto activo. Complementa git-commit. | [.agents/skills/structured-commits-ops/SKILL.md](.agents/skills/structured-commits-ops/SKILL.md) |
| `systematic-debugging` | Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes | [.agents/skills/systematic-debugging/SKILL.md](.agents/skills/systematic-debugging/SKILL.md) |
| `task-pipeline-ops` | Pipeline multi-paso proyecto activo: Plan → Spec → Exec → Verify → Fix (máx. 3). | [.agents/skills/task-pipeline-ops/SKILL.md](.agents/skills/task-pipeline-ops/SKILL.md) |
| `test-driven-development` | Use when implementing any feature or bugfix, before writing implementation code | [.agents/skills/test-driven-development/SKILL.md](.agents/skills/test-driven-development/SKILL.md) |
| `ui-router` | Orquesta precedencia UI/UX: skill dominio del producto, ui-ux-pro-max, responsive-design. | [.agents/skills/ui-router/SKILL.md](.agents/skills/ui-router/SKILL.md) |
| `ui-ux-pro-max` | UI/UX design intelligence: design system generator, 67+ styles, palettes, typography, UX guidelines, charts, google-fonts domain, stacks Flutter/React/Next/Vue/Tailwind/shadcn. | [.agents/skills/ui-ux-pro-max/SKILL.md](.agents/skills/ui-ux-pro-max/SKILL.md) |
| `using-git-worktrees` | Worktree aislado para features Flutter proyecto. Base dev. | [.agents/skills/using-git-worktrees/SKILL.md](.agents/skills/using-git-worktrees/SKILL.md) |
| `verification-before-completion` | OBLIGATORIO antes de declarar cualquier tarea completada en cualquier proyecto. Ejecuta verificación fresca del stack y solo entonces afirma éxito. | [.agents/skills/verification-before-completion/SKILL.md](.agents/skills/verification-before-completion/SKILL.md) |
| `webapp-testing` | Toolkit for interacting with and testing local web applications using Playwright. Supports verifying frontend functionality, debugging UI behavior, capturing browser screenshots, and viewing browser logs. | [.agents/skills/webapp-testing/SKILL.md](.agents/skills/webapp-testing/SKILL.md) |
| `work-unit-commits-ops` | Commits por unidad de trabajo reviewable: un propósito, tests/docs con el código, historia clara. Puente a chained PRs. | [.agents/skills/work-unit-commits-ops/SKILL.md](.agents/skills/work-unit-commits-ops/SKILL.md) |
| `writing-plans` | Plan bite-sized Flutter antes de codificar. .agents/plans/implementation_plan.md | [.agents/skills/writing-plans/SKILL.md](.agents/skills/writing-plans/SKILL.md) |
| **`zonix-admin-analytics-ui`** | **UI dashboards admin/commerce Zonix Pharma (Flutter). Métricas, tablas, filtros; alinear KPIs con zonix-analytics Backend.** | [.agents/skills/zonix-admin-analytics-ui/SKILL.md](.agents/skills/zonix-admin-analytics-ui/SKILL.md) |
| **`zonix-brand-ops`** | **Branding operativo Zonix Pharma — copia de referencia. Contenido completo en ZonixPharma-Backend.** | [.agents/skills/zonix-brand-ops/SKILL.md](.agents/skills/zonix-brand-ops/SKILL.md) |
| **`zonix-design-enforcer`** | **Enforcer de calidad visual Flutter Zonix Pharma — grid 8pt, WCAG, un CTA primario, tokens brand* obligatorios, M3/HIG, badges Rx. Complementa zonix-ui-design.** | [.agents/skills/zonix-design-enforcer/SKILL.md](.agents/skills/zonix-design-enforcer/SKILL.md) |
| **`zonix-empresa-ve`** | **Empresa VE (C.A., SAFE, laboral) — referencia Backend.** | [.agents/skills/zonix-empresa-ve/SKILL.md](.agents/skills/zonix-empresa-ve/SKILL.md) |
| **`zonix-founder-ops-index`** | **Índice founder CEO/CTO — referencia Backend.** | [.agents/skills/zonix-founder-ops-index/SKILL.md](.agents/skills/zonix-founder-ops-index/SKILL.md) |
| **`zonix-investor-materials`** | **Materiales inversor Zonix — referencia Backend. Data room en docs/Lanzamiento.** | [.agents/skills/zonix-investor-materials/SKILL.md](.agents/skills/zonix-investor-materials/SKILL.md) |
| **`zonix-jarvis-subagents-map`** | **Mapeo JARVIS — referencia Backend.** | [.agents/skills/zonix-jarvis-subagents-map/SKILL.md](.agents/skills/zonix-jarvis-subagents-map/SKILL.md) |
| **`zonix-lanzamiento-roles`** | **Panel roles pack Lanzamiento — referencia Backend.** | [.agents/skills/zonix-lanzamiento-roles/SKILL.md](.agents/skills/zonix-lanzamiento-roles/SKILL.md) |
| **`zonix-launch-piloto`** | **Plan piloto T+0→Day-D — referencia Backend.** | [.agents/skills/zonix-launch-piloto/SKILL.md](.agents/skills/zonix-launch-piloto/SKILL.md) |
| **`zonix-lean-canvas`** | **Lean Canvas piloto Zonix — referencia Backend (UniMOOC Steve Blank).** | [.agents/skills/zonix-lean-canvas/SKILL.md](.agents/skills/zonix-lean-canvas/SKILL.md) |
| **`zonix-legal-contracts-ve`** | **Contratos VE — referencia Backend.** | [.agents/skills/zonix-legal-contracts-ve/SKILL.md](.agents/skills/zonix-legal-contracts-ve/SKILL.md) |
| **`zonix-onboarding`** | **Onboarding Zonix Pharma (Flutter). Paciente (users), farmacia (commerce), farmacéutico (pharmacist); delivery desde paneles company/admin.** | [.agents/skills/zonix-onboarding/SKILL.md](.agents/skills/zonix-onboarding/SKILL.md) |
| **`zonix-order-lifecycle`** | **Ciclo de vida de órdenes Zonix Pharma (Flutter). pending_prescription_validation, timelines UI; alinear con Backend zonix-order-lifecycle.** | [.agents/skills/zonix-order-lifecycle/SKILL.md](.agents/skills/zonix-order-lifecycle/SKILL.md) |
| **`zonix-order-tracking-ui`** | **UI tracking de órdenes Zonix Pharma (Flutter). Estados Rx, timelines, mapa y pending_prescription_validation.** | [.agents/skills/zonix-order-tracking-ui/SKILL.md](.agents/skills/zonix-order-tracking-ui/SKILL.md) |
| **`zonix-realtime-events`** | **Eventos en tiempo real Zonix Pharma (Flutter). Pusher, FCM zonix_pharma_fcm; alinear con Backend zonix-realtime-events.** | [.agents/skills/zonix-realtime-events/SKILL.md](.agents/skills/zonix-realtime-events/SKILL.md) |
| **`zonix-startup-context`** | **Contexto canónico Zonix Pharma — copia de referencia. Contenido completo en ZonixPharma-Backend.** | [.agents/skills/zonix-startup-context/SKILL.md](.agents/skills/zonix-startup-context/SKILL.md) |
| **`zonix-ui-design`** | **Sistema de diseño visual de Zonix Pharma. Paleta fría Pharma (navy + teal + mint), tipografía Plus Jakarta Sans, cards de medicamento, badges Rx / cold chain / controlado, bottom nav por rol incluido pharmacist, layouts de receta médica.** | [.agents/skills/zonix-ui-design/SKILL.md](.agents/skills/zonix-ui-design/SKILL.md) |
| **`zonix-web-design`** | **Diseño web Blade/CSS Zonix Pharma — copia de referencia. Contenido completo en ZonixPharma-Backend.** | [.agents/skills/zonix-web-design/SKILL.md](.agents/skills/zonix-web-design/SKILL.md) |
| `zoom-out` | Explicar código o un cambio en el contexto del sistema completo del proyecto activo (módulos, capas, flujos). Uso bajo demanda. | [.agents/skills/zoom-out/SKILL.md](.agents/skills/zoom-out/SKILL.md) |
<!-- SKILLS-END -->

> **Skills financieras/regulatorias completas** (`zonix-financial-model`, `zonix-fundraising-narrative`, `zonix-regulatory-ve`): solo en [ZonixPharma-Backend/.agents/skills/](../ZonixPharma-Backend/.agents/skills/).

---

## Auto-invoke Skills

Aplicar precedencia de [`jarvis-core`](.agents/skills/jarvis-core/SKILL.md).

<!-- AUTO-INVOKE-START -->
| Acción | Skill |
|--------|-------|
| Abrir PR con gh | `branch-pr-ops` |
| Actualizar docs tras cambio de código | `docs-alignment-ops` |
| Agent loop engineering / no prompts haz loops | `agent-loop-engineering` |
| Alta stakes verificar antes de commit | `doubt-driven-development` |
| Auditar open issues como maintainer | `backlog-triage-ops` |
| Auditoría módulo | `fan-out-synthesize-ops` |
| Buscar contexto previo mem_search mem_context | `engram-memory-protocol` |
| Cambio API CLI setup que afecta documentación | `docs-alignment-ops` |
| Cerrar sesión con cambios | `documentar-avances` |
| Cierre sesión con mem_session_summary | `engram-memory-protocol` |
| Clasificar PRs merge request-changes close | `backlog-triage-ops` |
| Comando git destructivo | `git-guardrails-ops` |
| Compactar o traspasar sesion | `handoff` |
| Condiciones de terminación bucle autónomo | `human-in-the-loop-ops` |
| Configurar NotebookLM MCP en Cursor | `notebooklm-router` |
| Configurar engram en Cursor | `engram-router` |
| Constitución / SAFE / textos legales app (checklist) | `zonix-empresa-ve` |
| Consultar NotebookLM / notebook con citas | `notebooklm-router` |
| Copy / naming / branding app | `zonix-brand-ops` |
| Corpus grande de documentos para RAG | `notebooklm-router` |
| Crear commit | `git-commit` |
| Crear commit | `structured-commits-ops` |
| Crear commit | `verification-before-completion` |
| Crear o preparar pull request | `branch-pr-ops` |
| Crear/modificar pantallas o widgets | `zonix-ui-design` |
| Cualquier tarea no trivial | `fan-out-synthesize-ops` |
| Cualquier tarea no trivial | `jarvis-experts` |
| Decidir loop vs prompt simple | `agent-loop-engineering` |
| Decisión cross-rol | `jarvis-experts` |
| Decisión no trivial seguridad producción | `doubt-driven-development` |
| Definir alcance de un módulo | `jarvis-experts` |
| Diseñar UI o UX | `ui-router` |
| Diseñar UI o UX | `ui-ux-pro-max` |
| Diseñar UI/UX Flutter | `zonix-design-enforcer` |
| Diseñar UI/UX Flutter | `zonix-ui-design` |
| Diseñar loop de agente | `agent-loop-engineering` |
| Dividir diff grande en slices reviewables | `chained-pr-ops` |
| Dividir implementación en commits reviewables | `work-unit-commits-ops` |
| Doc largo, denso o difícil de escanear | `cognitive-doc-design-ops` |
| Día del juicio / jueces paralelos | `parallel-judge-ops` |
| Encontrar bug o test fallido | `systematic-debugging` |
| Escribir descripción de PR o notas para review | `cognitive-doc-design-ops` |
| Escribir feedback de code review para humano | `comment-writer-ops` |
| Estados / flujo de órdenes | `zonix-order-lifecycle` |
| Evitar PR monolítico desde SDD tasks | `work-unit-commits-ops` |
| Explorar codebase | `fan-out-synthesize-ops` |
| Finalizar tarea | `documentar-avances` |
| Gates humanos antes de acción irreversible | `human-in-the-loop-ops` |
| Guardar decisión o bugfix en Engram | `engram-memory-protocol` |
| HITL HOTL umbrales de confianza | `human-in-the-loop-ops` |
| Hacer git push o merge | `git-guardrails-ops` |
| Hitos piloto / calendario Day-D (solo planificación) | `zonix-launch-piloto` |
| Human-in-the-loop diseño de loop | `human-in-the-loop-ops` |
| Implementar Pusher / FCM | `zonix-realtime-events` |
| Implementar feature multi-archivo | `fan-out-synthesize-ops` |
| Implementar feature o bugfix | `test-driven-development` |
| Iniciar módulo | `brainstorming-ops` |
| Iniciar módulo | `jarvis-core` |
| Iniciar módulo | `task-pipeline-ops` |
| Investigar bug | `fan-out-synthesize-ops` |
| Iterar hasta lograr un objetivo medible | `agent-loop-engineering` |
| Landing page o dashboard | `ui-router` |
| Landing page o dashboard | `ui-ux-pro-max` |
| Memoria persistente Engram MCP | `engram-router` |
| Naming de branch y checklist pre-PR | `branch-pr-ops` |
| Nueva feature producto (spec en Backend hub) | `zonix-ui-design` |
| Onboarding (incluye pharmacist) | `zonix-onboarding` |
| PR supera 400 líneas o presupuesto de review | `chained-pr-ops` |
| Paleta de colores o tipografía | `ui-router` |
| Paleta de colores o tipografía | `ui-ux-pro-max` |
| Planificar desarrollo | `brainstorming-ops` |
| Planificar desarrollo | `jarvis-core` |
| Planificar desarrollo | `writing-plans` |
| Preparar commits antes de abrir PR | `work-unit-commits-ops` |
| Redactar comentario de PR o issue | `comment-writer-ops` |
| Redactar o mejorar README, RFC, onboarding o guía | `cognitive-doc-design-ops` |
| Requisitos ambiguos | `deep-interview-ops` |
| Respuesta de maintainer o mensaje async al equipo | `comment-writer-ops` |
| Revisar accesibilidad o layout | `ui-router` |
| Revisar accesibilidad o layout | `ui-ux-pro-max` |
| Revisar contrato / T&C farmacia (checklist) | `zonix-legal-contracts-ve` |
| Stacked PRs o chained PRs | `chained-pr-ops` |
| Tarea multi-rol (subagent + skill canon) | `zonix-jarvis-subagents-map` |
| Terminar módulo | `finishing-a-development-branch` |
| Terminar módulo | `jarvis-core` |
| Terminar módulo | `session-learner-ops` |
| Terminar módulo | `verification-before-completion` |
| Triage backlog issues y PRs | `backlog-triage-ops` |
| UI alineada a pack inversor / claims salud | `zonix-lanzamiento-roles` |
| UI alineada a pack inversor / claims salud | `zonix-startup-context` |
| Validar diff/PR con 2+ revisores independientes | `parallel-judge-ops` |
| Verificación adversarial paralela de un artefacto | `parallel-judge-ops` |
| Verificar que docs igualan comportamiento actual | `docs-alignment-ops` |
| doubt-driven revisión adversarial | `doubt-driven-development` |
| mem_save mem_search contexto entre sesiones | `engram-router` |
| nlm login nlm setup add cursor | `notebooklm-router` |
<!-- AUTO-INVOKE-END -->

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
