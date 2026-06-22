---
name: task-pipeline-ops
description: >
  Pipeline multi-paso proyecto activo: Plan → Spec → Exec → Verify → Fix (máx. 3).
  Trigger: Pantallas complejas, varios providers, flujos multi-paso.
license: UNLICENSED
metadata:
  version: "1.1.0"
  auto_invoke:
    - "Iniciar módulo"
  related-skills: [jarvis-core, verification-before-completion, writing-plans]
---

# Task pipeline ops — proyecto activo

Adaptado desde clawvis-openclaw.

## Pipeline

```
PLAN → SPEC → EXEC → VERIFY → FIX (≤3) → COMPLETE | ESCALATE
```

## Fase PLAN

- `.agents/plans/implementation_plan.md`
- Aprobación usuario

## Fase SPEC

| Paso | Done when |
|------|-----------|
| Pantalla | Widget monta sin overflow; analyze limpio |
| Provider | Estado coherente; tests si existen |

## Fase VERIFY

- `flutter analyze` + `flutter test` (evidencia en el turno)

## Cierre

- `walkthrough.md` + opcional `docs/active_context.md` vía `session-learner-ops`

---

## Overlay ZonixPharma Front

Pipeline: PLAN → SPEC → EXEC → VERIFY → FIX (≤3) → COMPLETE | ESCALATE

### SPEC (Flutter)

| Paso | Done when |
|------|-----------|
| Pantalla | `flutter analyze` limpio + tests widget/feature |
| Integración API | Contrato alineado con Backend `zonix-api-patterns` |
| Feature Spec Kit | Plan/tasks en Backend `specs/` |

### VERIFY

`flutter analyze` + `flutter test` + `verification-before-completion`.

### Cierre

`docs/active_context.md`, `documentar-avances` si aplica.
