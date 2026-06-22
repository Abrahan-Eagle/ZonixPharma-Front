## Overlay ZonixPharma Front

Roster y combinaciones para Flutter Zonix Pharma. Ver `AGENTS.md` + `zonix-jarvis-subagents-map` (Backend).

### Especialización

App marketplace farmacéutico: onboarding multi-rol, checkout Rx, cadena de frío UI, FCM/Pusher, tokens `AppColors`.

### Combinaciones recomendadas

| Tipo de tarea | Combinación |
|---------------|-------------|
| Pantalla checkout Rx | frontend + UX + AppSec |
| Onboarding pharmacist | frontend + UX writer |
| Realtime chat/orders UI | frontend + mobile platform |
| Refactor feature grande | arquitecto + tech lead + QA |
| Claims salud en copy UI | UX writer + Backend `zonix-regulatory-ve` (lente) |

### Anti-patrones

- Más de 3 roles declarados.
- UI sin `zonix-ui-design` / `AppColors`.
- Spec Kit para pack Lanzamiento.

### Review adversarial

| Momento | Skill |
|---------|-------|
| Duda in-flight | `doubt-driven-development` |
| Pre-merge UI Rx/checkout | `parallel-judge-ops` |
