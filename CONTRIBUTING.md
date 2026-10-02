# 🤝 Guía de Contribución — Centrix Mobile

Bienvenido/a al repositorio de **Centrix Mobile**. Este documento establece las normas que todo colaborador debe seguir para mantener la calidad y coherencia del proyecto.

> **Leer antes de hacer un Pull Request.** El cumplimiento de estas guías es condición necesaria para el merge.

---

## 📋 Tabla de Contenidos

1. [Código de Conducta](#código-de-conducta)
2. [Cómo Reportar Bugs](#cómo-reportar-bugs)
3. [Cómo Proponer Features](#cómo-proponer-features)
4. [Workflow de Git](#workflow-de-git)
5. [Convención de Commits](#convención-de-commits)
6. [Versionado Semántico](#versionado-semántico)
7. [Guía de Estilo de Código](#guía-de-estilo-de-código)
8. [Pipeline de CI](#pipeline-de-ci)
9. [Proceso de Code Review](#proceso-de-code-review)

---

## 📜 Código de Conducta

Todos los participantes deben ser respetuosos, inclusivos y profesionales. Cualquier comportamiento inapropiado puede reportarse al equipo responsable del proyecto.

---

## 🐛 Cómo Reportar Bugs

1. Verifica que el bug **no haya sido reportado antes** buscando en [Issues](../../issues).
2. Crea un nuevo Issue con la plantilla **Bug Report**.
3. Incluye:
   - Versión de la app (`vX.Y.Z+build`)
   - Dispositivo y versión de OS
   - Pasos para reproducir
   - Comportamiento esperado vs. obtenido
   - Capturas de pantalla o logs de Crashlytics

---

## 💡 Cómo Proponer Features

1. Abre un Issue con la plantilla **Feature Request** antes de escribir código.
2. Describe el problema que resuelve y el valor que aporta.
3. Espera aprobación del equipo antes de iniciar el desarrollo.

---

## 🌿 Workflow de Git

El proyecto sigue **GitHub Flow** con un subconjunto de ramas de Gitflow para releases:

```
main            ← producción estable (protegida, solo merge via PR)
  └── develop   ← integración continua (Internal Testing)
        ├── feature/<nombre-corto>    ← nuevas funcionalidades
        ├── fix/<nombre-corto>        ← correcciones de bugs
        └── chore/<nombre-corto>      ← mantenimiento / deps

release/vX.Y.Z  ← candidata a producción (Alpha → Beta)
hotfix/vX.Y.Z   ← parche crítico en producción (sale de main, merge a main + develop)
```

### Reglas de ramas

| Rama | Descripción | Direct push |
|------|-------------|-------------|
| `main` | Producción. Solo merge via PR aprobado | ❌ Bloqueado |
| `develop` | Base de integración | ❌ Bloqueado |
| `feature/**` | Funcionalidades nuevas | ✅ Permitido |
| `fix/**` | Corrección de bugs | ✅ Permitido |
| `hotfix/**` | Parches de emergencia | ✅ Permitido |
| `release/**` | Release candidata | ✅ Permitido |

### Ciclo de vida de una feature

```bash
# 1. Actualiza develop
git checkout develop && git pull origin develop

# 2. Crea tu rama de feature
git checkout -b feature/mi-nueva-feature

# 3. Desarrolla, commitea y pushea
git add .
git commit -m "feat(auth): add biometric login support"
git push origin feature/mi-nueva-feature

# 4. Abre un Pull Request hacia develop
# → El CI corre automáticamente
# → Espera 1 aprobación mínima de revisión de código
# → Merge con squash o merge commit (no rebase en repos compartidos)
```

---

## 📝 Convención de Commits

Usamos **[Conventional Commits](https://www.conventionalcommits.org/)** v1.0.0. Todos los mensajes de commit **deben** seguir este formato:

```
<tipo>(<alcance>): <descripción corta en imperativo>

[cuerpo opcional — explicación del "por qué"]

[pie opcional — referencias a issues, breaking changes]
```

### Tipos permitidos

| Tipo | Cuándo usarlo |
|------|---------------|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de bug |
| `perf` | Mejora de rendimiento |
| `refactor` | Reestructuración sin cambio funcional |
| `test` | Agregar o corregir pruebas |
| `docs` | Solo documentación |
| `chore` | Actualizaciones de build, deps, config |
| `ci` | Cambios en el pipeline de CI |
| `style` | Formato de código (sin lógica) |
| `revert` | Reversa de un commit anterior |

### Alcances sugeridos

`auth`, `dashboard`, `core`, `ci`, `deps`, `navigation`, `ui`, `api`

### Ejemplos válidos ✅

```
feat(auth): add email validation in login form
fix(auth): prevent duplicate login requests on fast tap
test(core): add unit tests for FormValidator utility
chore(deps): upgrade flutter_lints to 3.0.0
ci: add Android APK artifact upload step
docs: update CONTRIBUTING.md with commit convention
```

### Ejemplos inválidos ❌

```
fix stuff               ← sin tipo ni alcance
WIP                     ← no descriptivo
Update files            ← demasiado genérico
fixed bug in login      ← no sigue el formato
```

### Breaking Changes

Si el commit introduce un cambio incompatible con versiones anteriores, añade `!` después del tipo y documenta en el pie:

```
feat(api)!: change login endpoint response schema

BREAKING CHANGE: `data.user` ya no incluye el campo `role`.
Los clientes deben usar el nuevo endpoint `/auth/profile` para obtenerlo.
```

---

## 🔢 Versionado Semántico

El proyecto sigue **[Semantic Versioning 2.0.0](https://semver.org/)** con build number para las tiendas:

```
vMAJOR.MINOR.PATCH (build BUILD_NUMBER)
Ejemplo: v1.2.3 (build 45)
```

### Reglas de incremento

| Componente | Cuándo incrementar |
|------------|-------------------|
| `MAJOR` | Breaking change en la API pública o cambio de arquitectura mayor |
| `MINOR` | Nueva funcionalidad compatible con versiones anteriores |
| `PATCH` | Corrección de bug compatible con versiones anteriores |
| `build` | Cada build de CI (se incrementa automáticamente) |

### Correspondencia en `pubspec.yaml`

```yaml
# v1.2.3 (build 45)
version: 1.2.3+45
#        ^^^^^  ^^ build number (versionCode en Android / CFBundleVersion en iOS)
#        MAJOR.MINOR.PATCH
```

### Tags de Git

Cada release debe tener un tag anotado:

```bash
git tag -a v1.2.3 -m "Release v1.2.3: descripción breve"
git push origin v1.2.3
```

---

## 🎨 Guía de Estilo de Código

### Dart / Flutter

- Seguir la [Guía de Estilo Efectiva de Dart](https://dart.dev/effective-dart).
- Usar `dart format` antes de cada commit (el CI lo verifica).
- Respetar todas las reglas de `flutter_lints` configuradas en `analysis_options.yaml`.
- No dejar warnings pendientes (`flutter analyze --fatal-warnings`).

### Arquitectura

- Seguir la estructura **MVVM** establecida: `data/`, `viewmodel/`, `view/`.
- La lógica pura (validadores, formateadores, utilidades) va en `lib/core/utils/`.
- La configuración de la app (feature flags, constants) va en `lib/core/config/`.
- **No** importar paquetes de Flutter (widgets) en la capa `data/` o `viewmodel/`.

### Pruebas

- Cada función pura en `lib/core/utils/` **debe** tener pruebas unitarias en `test/core/utils/`.
- Cada ViewModel **debe** tener pruebas unitarias con mocks en `test/features/<feature>/viewmodel/`.
- La cobertura mínima aceptada es **80%** para lógica de negocio.

---

## ⚙️ Pipeline de CI

El pipeline se ejecuta automáticamente en cada PR hacia `main` y `develop`:

```
PR abierto
  └── [Job 1] lint → dart analyze + dart format (check)
        └── [Job 2] test → flutter test --coverage
              └── [Job 3] build-android → flutter build apk --debug
                    └── [Job 4] ci-status → gate de aprobación
```

**El merge está bloqueado** hasta que los 4 jobs estén en verde.

Para ejecutar los checks localmente antes de hacer push:

```bash
# Desde el directorio centrix_mobile/
flutter pub get
dart format --output=none --set-exit-if-changed lib/ test/
flutter analyze --fatal-infos --fatal-warnings
flutter test --coverage test/
```

---

## 👀 Proceso de Code Review

### Para el autor del PR

1. Asegúrate de que el CI esté en verde antes de solicitar revisión.
2. Completa toda la plantilla del PR.
3. Asigna al menos 1 revisor.
4. Responde todos los comentarios antes del merge.

### Para el revisor

| Aspecto | Qué verificar |
|---------|---------------|
| **Corrección** | ¿El código hace lo que dice el PR? |
| **Pruebas** | ¿Hay pruebas unitarias para la lógica nueva? |
| **Arquitectura** | ¿Sigue el patrón MVVM? ¿No mezcla capas? |
| **Estilo** | ¿Sigue las convenciones de nombres de Dart? |
| **Seguridad** | ¿No hay credenciales o datos sensibles hardcodeados? |
| **Rendimiento** | ¿No hay rebuilds innecesarios de widgets? |

### Tiempo de respuesta

- Los revisores tienen **48 horas** para completar la revisión.
- Si no hay respuesta, el autor puede hacer merge con la aprobación del tech lead.

---

## 📄 Licencia

Al contribuir, aceptas que tus contribuciones sean licenciadas bajo los mismos términos que el proyecto.

---

*Última actualización: Septiembre 2026 — Equipo Centrix*
