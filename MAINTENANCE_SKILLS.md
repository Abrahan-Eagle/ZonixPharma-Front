# Guía de Mantenimiento de Skills y Coherencia — Zonix Pharma

Esta guía define las reglas para mantener la integridad y coherencia del sistema de documentación y lógica procedimental de **Zonix Pharma**. Es de lectura obligatoria para cualquier IA o humano que desee modificar las **Custom Skills**.

---

## 1. El Sistema de Skills (Por qué existe)

Las skills (`.agents/skills/*/SKILL.md`) no son simple documentación; son **guías procedimentales** para que la IA actúe como un experto especializado. Transforman a una IA genérica en un "Zonix Engineer" que conoce recetas Rx, cadena de frío, pagos VE y el sistema de diseño Pharma sin redescubrirlos cada vez.

---

## 2. Capas de skills y sync global (Paso C — jarvis-skills-library)

| Capa | Patrón | Ejemplos |
|------|--------|----------|
| 0 Máquina | `~/.cursor/skills/` | `jarvis-core`, `sdd-router` |
| 0 Global-sync | `.global-sync-manifest` | `ui-router`, `ui-ux-pro-max` (overlay) |
| 3 Dominio Zonix | `zonix-*` | **solo locales** |
| 5 Solo local | no en manifest | `playwright-skill`, Stitch/React, `speckit-git-*` |

```bash
JARVIS_SKILLS_LIBRARY=/var/www/html/proyectos/AIPP/jarvis-skills-library \
  ./scripts/sync-global-skills-from-library.sh
./scripts/check-global-skills-sync.sh
python3 .agents/skills/sync.sh
bash $JARVIS_SKILLS_LIBRARY/scripts/init-jarvis.sh --min c
```

- **`ui-ux-pro-max`:** editar [.agents/skills/ui-ux-pro-max/OVERLAY.md](.agents/skills/ui-ux-pro-max/OVERLAY.md) (canon marca en Backend `docs/BRAND_ZONIX_PHARMA.md`).
- **Spec Kit:** core en `~/.cursor/skills/` (`install.sh --all`); git hooks en `.agents/skills/speckit-git-*`. `.cursor/skills/` gitignored — ver [../ZonixPharma-Backend/docs/ZONIX_JARVIS_INTEGRATION.md](../ZonixPharma-Backend/docs/ZONIX_JARVIS_INTEGRATION.md).

---

## 3. Precedencia de diseño y branding (obligatoria)

Al tocar UI, copy o CSS, aplicar este orden **sin excepción**:

```
1. docs/BRAND_ZONIX_PHARMA.md (Backend — canon de marca)
2. zonix-ui-design (Flutter) | zonix-web-design (Blade/CSS)
3. zonix-brand-ops | zonix-design-enforcer
4. ui-ux-pro-max | frontend-design (genéricas — NO overridean tokens)
5. enhance-prompt / design-md (solo Stitch, no Flutter diario)
```

**Regla:** Las skills genéricas (`ui-ux-pro-max`, `frontend-design`) son **secundarias**. Nunca introducir HEX, gradientes purple AI-slop ni paletas fuera de tokens `brand*` / variables CSS en `zonix.css`.

---

## 3. Skills de branding y diseño (Jun 2026)

| Skill | Repo canon | Stub en otro repo |
| ----- | ---------- | ----------------- |
| `zonix-brand-ops` | Backend | Front |
| `zonix-web-design` | Backend | Front |
| `zonix-design-enforcer` | Front | Backend |
| `zonix-ui-design` | Front | — |

**Auto-invoke (resumen):**

- Flutter UI → `zonix-ui-design` + `zonix-design-enforcer`
- Copy / naming / ASO → `zonix-brand-ops`
- Landing Blade / `zonix.css` → `zonix-web-design` + `zonix-brand-ops`

---

## 4. Terminología Estándar de Roles

Cualquier cambio en código o docs **DEBE** usar esta nomenclatura:

| Nivel | Código en BD | Nombre Estándar | Alias aceptados |
| ----- | ------------ | --------------- | --------------- |
| 0 | `users` | **Buyer** | Paciente, Cliente |
| 1 | `commerce` | **Pharmacy** | Farmacia, Comercio |
| 2 | `delivery` | **Delivery** | Repartidor |
| 3 | `admin` | **Admin** | Administrador |

> En docs legacy puede aparecer "Commerce"; en UI preferir **Farmacia**.

---

## 5. Reglas de Oro para Actualizaciones

### 5.1. Auditoría Previa (Mandatorio para IAs)

Antes de proponer un cambio en una skill o en `README.md`, la IA debe:

1. Leer skills custom relevantes (Front ~45, Backend ~56; contar con `find .agents/skills -name SKILL.md | wc -l`).
2. Identificar impacto cross-dominio (ej: cambio Rx afecta `zonix-prescriptions`, `zonix-order-lifecycle`, UI badges).
3. Verificar que colores/copy sigan `BRAND_ZONIX_PHARMA.md`.

### 5.2. Sincronización Cross-Project

Zonix Pharma se divide en `ZonixPharma-Backend` y `ZonixPharma-Front`.

- Skills de lógica compartida (`zonix-order-lifecycle`, `zonix-realtime-events`) deben mantenerse alineadas.
- Skills con **stub** en un repo apuntan al **canon** en el otro; actualizar el canon primero, luego verificar que el stub siga siendo válido.

### 5.3. Cross-References

Toda skill debe referenciar otras si hay solapamiento:

- `zonix-brand-ops` → `zonix-web-design`, `zonix-ui-design`
- `zonix-design-enforcer` → `zonix-ui-design`, `zonix-brand-ops`
- `zonix-web-design` → `BRAND_ZONIX_PHARMA.md`, `zonix.css`

---

## 6. Infraestructura Crítica (Inamovible)

1. **NO WebSockets nativos:** Pusher Channels + FCM.
2. **Canales privados:** Actualizaciones de orden usan canales `private-`.
3. **Roles:** Solo 4 niveles (0–3).
4. **Deprecaciones:** `profiles.phone` no debe usarse; teléfonos en tabla `phones`.
5. **Tokens de color:** `AppColors.brand*` (Flutter) y variables en `public/css/zonix.css` (web).

---

## 7. Cómo Hacer Cambios (IA Flow)

1. **Analizar:** Leer `AGENTS.md` y este archivo.
2. **Proponer:** Plan detallando skills a modificar; respetar precedencia §2.
3. **Ejecutar:** Aplicar cambios; frontmatter `related-skills` en skills nuevas.
4. **Verificar:** `grep SKILLS-START AGENTS.md`; skills no deben introducir HEX fuera de BRAND.

---

**Última actualización:** 21 junio 2026  
**Zonix Team**
