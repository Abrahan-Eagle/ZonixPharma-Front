## Overlay ZonixPharma Front

### Flujo ramas Zonix

| Rama | Destino |
|------|---------|
| `dev` | staging / test |
| `main` | producción (`zonixpharma.com`) |

**Flujo:** `dev` → probar → merge `main` solo con orden explícita.

### Bloqueados sin OK explícito

`git push`, merge a `main`, `--force`, `git reset --hard`.

Checklist push: orden usuario, rama correcta, `flutter analyze` + `flutter test` pasaron.
