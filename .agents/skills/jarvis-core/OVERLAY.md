## Overlay ZonixPharma Front

Extensión producto Flutter marketplace farmacéutico VE. **Precede sobre la base global** donde se contradiga.

### Skill Bootstrap (Paso 0 — tareas no triviales)

Antes de editar código:

1. `Read` → `.agents/skills/SKILL_INDEX.md`.
2. `Read` → `.agents/skills/jarvis-core/SKILL.md`.
3. Consultar auto-invoke en `AGENTS.md`.
4. Declarar en la **primera respuesta** (junto a `> Roles:`):

```text
> Skills: ui-router (local) → zonix-ui-design (local) → ui-ux-pro-max (local)
```

5. `Read` cada skill declarada **antes** de implementar.

**Capas:** `local` = `.agents/skills/` · `global` = `~/.cursor/skills/`.

### Spec Kit / SDD (activo en Zonix)

Features de **producto** siguen Spec Kit en hub Backend (`specs/`). Front es espejo de implementación.

| Ámbito | Cadena |
|--------|--------|
| Feature producto | `sdd-router` (global) → `.cursor/skills/speckit-*` → `zonix-ui-design` / `zonix-order-lifecycle` |
| Guía | [../ZonixPharma-Backend/docs/zonix/SPEC_KIT_ZONIX.md](../ZonixPharma-Backend/docs/zonix/SPEC_KIT_ZONIX.md) |

**No Spec Kit** para `docs/Lanzamiento/` → Backend `zonix-lanzamiento-docs`.

### Panel de expertos + routing Zonix

| Capa | Skill |
|------|-------|
| 1 | `jarvis-experts` — roles Flutter/UX/AppSec |
| 2 | `zonix-jarvis-subagents-map` (stub → Backend) — routing dominio |
| 3 | `zonix-lanzamiento-roles` (stub → Backend) — pack inversor |

### Protocolo de calidad (Zonix Front)

| Skill | Cuándo |
|-------|--------|
| `deep-interview-ops` | Requisitos vagos |
| `brainstorming-ops` | Antes de UI nueva (fuera de spec aprobada) |
| `verification-before-completion` | **Obligatorio** (`flutter analyze` + `flutter test`) |
| `parallel-judge-ops` | Diffs UI Rx/checkout de alto riesgo |
| `human-in-the-loop-ops` | Push/merge sin OK explícito |

### Precedencia Zonix Front

| Fase | Cadena |
|------|--------|
| Tarea no trivial | `jarvis-experts` → `zonix-jarvis-subagents-map` (si aplica) |
| UI/UX en código | **`ui-router` → `zonix-ui-design` → `ui-ux-pro-max`** |
| Nueva feature producto | Spec Kit + `zonix-ui-design` + dominio (`zonix-order-lifecycle`, etc.) |
| Implementar pantalla | `test-driven-development` + `flutter-expert` |
| Onboarding | `zonix-onboarding` |
| Realtime | `zonix-realtime-events` |
| Terminar módulo | `verification-before-completion` → `session-learner-ops` |
| Crear commit | `verification-before-completion` → `work-unit-commits-ops` → `git-commit` |
| Push / merge | `git-guardrails-ops` |

### Workflow modular

1. Roles — declarar `> Roles:`.
2. Spec o plan — Backend `specs/` o `.agents/plans/`.
3. Desarrollo — Provider, features, `AppColors` / Theme.
4. Testing — `flutter analyze`, `flutter test`.
5. Memoria — `docs/active_context.md`.

**Canon workspace:** [../ZonixPharma-Backend/docs/ZONIX_WORKSPACE.md](../ZonixPharma-Backend/docs/ZONIX_WORKSPACE.md).

**Stitch/React skills:** capa 5/6 local — no en manifest global (igual que CorralX Front).
