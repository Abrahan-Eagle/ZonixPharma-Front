## Overlay ZonixPharma Front — ui-ux-pro-max

Precede sobre queries BM25 genéricas. Leer **`zonix-ui-design`** y canon de marca antes de aplicar tokens.
Canon compartido Blade + anti-patterns: `../ZonixPharma-Backend/.agents/skills/ui-ux-pro-max/ZONIX.md`.

### Producto

- **Nombre:** Zonix Pharma
- **Vertical:** Marketplace farmacéutico (Venezuela, OTC + Rx)
- **Stack UI:** Flutter (Android, iOS, Web)

### Fuente canónica de tokens

| Recurso | Ruta |
|---------|------|
| Skill dominio | `.agents/skills/zonix-ui-design/SKILL.md` |
| Enforcer | `.agents/skills/zonix-design-enforcer/SKILL.md` |
| Marca (canon Backend) | `../ZonixPharma-Backend/docs/BRAND_ZONIX_PHARMA.md` |
| Colores Dart | `lib/features/utils/app_colors.dart` |

### Precedencia (obligatoria)

```
1. docs/BRAND_ZONIX_PHARMA.md (Backend)
2. zonix-ui-design → zonix-design-enforcer
3. zonix-brand-ops (stub → Backend)
4. ui-ux-pro-max (patrones UX; NO override tokens brand*)
5. frontend-design (secundaria)
```

**Regla:** Nunca sustituir `AppColors.brand*` ni paletas genéricas del CSV por tokens fuera de BRAND.

### Comando design system (Pharma)

```bash
export UI_UX_SKILL_ROOT="${UI_UX_SKILL_ROOT:-$HOME/.cursor/skills/ui-ux-pro-max}"

python3 "$UI_UX_SKILL_ROOT/scripts/search.py" \
  "pharmacy healthcare marketplace trust venezuela" \
  --design-system -p "Zonix Pharma" -f markdown

python3 "$UI_UX_SKILL_ROOT/scripts/search.py" "navigation forms cards listing" \
  --stack flutter
```

Mapear colores sugeridos a: `brandNavy`, `brandTeal`, `brandTealDeep`, `brandMint`.

### Anti-patterns Zonix

- Purple/pink AI-slop gradients
- Emojis como iconos (usar Material Icons / SVG)
- Paletas/fuentes fuera de Plus Jakarta Sans
- Copy gig-economy / restaurante / Eats legacy
- Ratings fake o claims de salud sin respaldo regulatorio
- Ignorar badges Rx / cold chain en checkout

### Skills financieras/regulatorias completas

Solo en Backend: `zonix-financial-model`, `zonix-fundraising-narrative`, `zonix-regulatory-ve`.
