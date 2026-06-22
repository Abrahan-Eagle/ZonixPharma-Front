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
