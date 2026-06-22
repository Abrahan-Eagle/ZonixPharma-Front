---
name: zonix-design-enforcer
description: Enforcer de calidad visual Flutter Zonix Pharma — grid 8pt, WCAG, un CTA primario, tokens brand* obligatorios, M3/HIG, badges Rx. Complementa zonix-ui-design.
trigger: Revisar o implementar pantallas Flutter, refactor UI, PR visual, contraste, spacing, anti-patterns Colors.*.
scope: lib/features/**, lib/features/utils/app_colors.dart, lib/features/utils/app_theme.dart
related-skills: zonix-ui-design, zonix-brand-ops, ui-ux-pro-max, mobile-developer, responsive-design
author: Zonix Team
version: 1.0
metadata:
  auto_invoke: "Diseñar UI/UX Flutter"
---
# Zonix Pharma — Design Enforcer (Flutter)

> Sistema de componentes: `zonix-ui-design`.
> Marca: [../../../ZonixPharma-Backend/docs/BRAND_ZONIX_PHARMA.md](../../../ZonixPharma-Backend/docs/BRAND_ZONIX_PHARMA.md).
> Tokens: [lib/features/utils/app_colors.dart](../../../lib/features/utils/app_colors.dart).

## Precedencia JARVIS

1. `BRAND_ZONIX_PHARMA.md`
2. `zonix-ui-design` (componentes y patrones Pharma)
3. **Esta skill** (heurísticas transversales)
4. `ui-ux-pro-max` — ideas UX; **no** reemplaza tokens `brand*`

## Grid 8pt (spacing)

Todo padding/margin/gap en múltiplos de **8**: 8, 16, 24, 32, 48.

| Uso | Valor típico |
| --- | ------------ |
| Padding lateral pantalla | 16–24 |
| Entre cards en lista | 16 |
| Padding interno card | 16–20 |
| Separación secciones | 24–32 |

Evitar `13`, `15`, `18`, `22` salvo alineación óptica documentada.

## Tokens de color (obligatorio)

- Usar **`AppColors.brand*`** y helpers (`scaffoldBg`, `cardBg`, `primaryText`, `secondaryText`)
- **Prohibido** añadir `Colors.red`, `Color(0xFF…)` en pantallas nuevas
- Aliases legacy (`AppColors.blue`, etc.): no añadir usos nuevos — migrar a `brand*`

## Jerarquía por pantalla

1. **Un** CTA primario (`brandTeal` — ElevatedButton/FAB principal)
2. Acciones secundarias: TextButton o outlined navy/tealDeep
3. Texto: primary → secondary → disabled (tres niveles max visibles)

## WCAG / contraste

- Botones light con fondo teal: `foregroundColor: AppColors.brandNavy` (ya en `app_theme.dart`)
- Body sobre fondo claro/oscuro: ≥ **4.5:1** (ver BRAND §5)
- No depender solo del color para estado (añadir icono o label)

## Badges Pharma (obligatorios si aplica)

Según `zonix-ui-design`:

- **Receta:** `brandTealDeep` + fondo alpha
- **Controlado:** `statusError`
- **Cadena de frío:** `statusInfo` + icono `ac_unit`

## Plataforma nativa

| Plataforma | Regla |
| ---------- | ----- |
| Android | Material 3; ripple/elevation coherentes con tema |
| iOS | SafeArea; respetar back gesture; tab bar legible (HIG) |
| Ambos | Área táctil mínima **48×48** lógicos en controles clicables |

No imitar iOS en Android con controles custom que rompan Material (ni viceversa).

## Anti-patterns Flutter

- Múltiples FAB teal en la misma pantalla
- `Colors.white`/`Colors.black` directo en widgets de feature (usar tema/AppColors)
- Gradientes purple o paletas no BRAND
- Copy o iconos de comida/restaurant en flujos Pharma

## Checklist pre-merge UI

- [ ] `flutter analyze` sin warnings nuevos en archivos tocados
- [ ] Spacing en grid 8pt
- [ ] Un CTA primario claro
- [ ] Sin `Colors.*` / `Color(0x` nuevo en `lib/features/`
- [ ] Rx/cold chain badges si el producto lo requiere
- [ ] Dark mode: texto legible sobre `brandSurfaceDark`

## Verificación rápida

```bash
rg "Colors\.(red|blue|green|orange|purple)|Color\(0x" lib/features/ --glob "*.dart"
rg "AppColors\.(blue|orange|red|green|purple)" lib/features/ --glob "*.dart"  # aliases legacy — tendencia a cero
```

## Skills relacionadas

- `zonix-ui-design` — cards medicamento, checkout Rx, bottom nav
- `zonix-brand-ops` (Backend) — naming/copy
- `zonix-web-design` (Backend) — paridad web
