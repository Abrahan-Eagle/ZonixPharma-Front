---
name: jarvis-experts
description: >
  Panel de Expertos JARVIS (agencia de desarrollo virtual). Define roster de roles,
  criterios de activación, combinaciones recomendadas y plantilla de declaración.
  Trigger: Antes de planificar/ejecutar tareas técnicas o decisiones cross-rol.
license: UNLICENSED
metadata:
  author: JARVIS Global
  version: "2.1"
  scope: [global]
  auto_invoke:
    - "Cualquier tarea no trivial"
    - "Decisión cross-rol"
    - "Definir alcance de un módulo"
  triggers: experto, expertos, agencia, panel, rol, roles, jarvis-experts
  related-skills:
    - jarvis-core
    - agent-loop-engineering
allowed-tools: [Read, Glob, Grep, Task]
---

# Panel de Expertos JARVIS (global)

## Cómo usar

1. **Identifica** 1–3 roles primarios para la tarea.
2. **Declara** al inicio: `> Roles: backend (Laravel) + AppSec`.
3. **Combina** roles secundarios automáticamente cuando la tarea lo exige.
4. **No spam:** no listar el roster entero ni declarar roles en tareas triviales.
5. Tras elegir roles, seguir precedencia en `jarvis-core`.

El roster detallado del **producto activo** está en `AGENTS.md` del repo. Esta skill define el patrón genérico.

## Roster genérico

| Área | Rol | Activar cuando… |
|------|-----|-----------------|
| Dirección | CTO / Tech lead | trade-offs, roadmap, CI/CD |
| Dirección | Arquitecto | diseño sistema, integraciones, escalabilidad |
| Desarrollo | Backend | APIs, servicios, BD, jobs |
| Desarrollo | Frontend / Mobile | UI, estado cliente, navegación |
| Plataforma | DevOps / SRE | deploy, observabilidad, incidentes |
| Calidad | QA / SDET | tests, fixtures, E2E |
| Calidad | AppSec | auth, secretos, OWASP |
| Producto | PM / UX / UX writer | scope, copy, flujos |
| Entrega | Delivery / BA | requisitos, stakeholders |
| Soporte | Technical writer | docs, repro bugs |

## Combinaciones típicas

| Tarea | Combinación |
|-------|-------------|
| Pantalla nueva | frontend + UX writer + a11y |
| Auth / tokens | backend + AppSec |
| Push / realtime | backend + frontend + integraciones |
| Migración BD | backend + DBA |
| Release | DevOps + QA |
| Copy y errores API | UX writer + backend o frontend |

## Especialización por producto

Consultar `AGENTS.md` del repo para dominio (`{producto}-*` skills en `.agents/skills/`).

## Delegation triggers (gentle-ai)

Mantén el hilo orquestador **delgado**. Cuando la tarea deja de ser pequeña, delegar o acotar fase SDD es **esperado**, no opcional. Fuente: [gentle-ai README](https://github.com/Gentleman-Programming/gentle-ai/blob/main/README.md). Ver también `agent-loop-engineering`.

| Trigger | Comportamiento JARVIS |
|---------|----------------------|
| Leer **4+ archivos** para entender un flujo | Task `explore` (readonly) o fase de exploración (`speckit-clarify`, Task subagent) |
| Tocar **2+ archivos no triviales** | Un writer thread; review fresco antes de cerrar (`code-review-playbook`, `parallel-judge-ops`) |
| Commit, push o PR tras cambios de código | Review fresco salvo diff trivial (docs/texto) — `verification-before-completion` |
| cwd equivocado, worktree/git accident, merge recovery, test/env confuso | **Parar** y auditar (`systematic-debugging`) antes de continuar |
| Sesión monolítica larga con complejidad acumulada | Pausar, delegar, re-planificar (`brainstorming-ops`, `handoff`) o justificar por qué no |
| Review adversarial de diffs, conflictos, PR readiness o incidentes | Contexto fresco: Task `readonly` (`parallel-judge-ops`, `doubt-driven-development`) |

Objetivo: evitar caos accidental con **un orquestador responsable** y **un writer thread**.

## Anti-patrones

- Más de 3 roles declarados
- Rol sin justificación (CTO en fix de typo)
- Pedir permiso para activar AppSec en cambio de auth
- Explorar 6 archivos en el hilo principal sin delegar
- Mezclar exploración + implementación + review en una sola vuelta monolítica

## Referencias

- `AGENTS.md` del proyecto — roster y reglas locales
- `jarvis-core` — workflow modular

---

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
