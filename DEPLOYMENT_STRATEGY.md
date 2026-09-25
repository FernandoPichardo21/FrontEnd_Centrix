# 📋 Estrategia de Despliegue y Distribución Móvil — Centrix Mobile

> **Documento:** Instrucción 4 – Estrategia de Despliegue y Distribución  
> **Proyecto:** FrontEnd_Centrix / `centrix_mobile` (Flutter)  
> **Versión:** 1.0 — Septiembre 2026

---

## 1. Contexto del Caso de Estudio

Centrix Mobile es la aplicación móvil Flutter que implementa el módulo de autenticación sobre arquitectura MVVM con Provider. El proyecto se encuentra en **fase inicial** (v1.0.0+1), con una única feature implementada (Login), pero con arquitectura de capas (data / viewmodel / view) lista para escalar.

Las decisiones de despliegue deben balancear:
- **Riesgo bajo** en las primeras versiones (base de usuarios potencialmente grande).
- **Velocidad de iteración** para un equipo pequeño.
- **Compatibilidad dual** Android (Google Play) e iOS (App Store).

---

## 2. Estrategias Evaluadas

### 2.1 Big Bang / Corte Total

| Criterio | Evaluación |
|---|---|
| Velocidad de entrega | ✅ Alta |
| Riesgo | ❌ Muy alto |
| Reversibilidad | ❌ Difícil |
| Adecuado para v1.0 | ❌ No recomendado |

**Descripción:** Se lanza la nueva versión a **todos los usuarios simultáneamente**, sin período de transición.

**Justificación del rechazo:** Para Centrix Mobile, donde el módulo de autenticación es crítico (cualquier fallo impide el acceso completo a la app), un corte total en producción podría generar pérdida masiva de sesiones o bloqueo total. No existe aún un historial de estabilidad en producción que justifique este nivel de confianza.

---

### 2.2 Canales de Prueba / Preview (Interno → Alpha → Beta)

| Canal | Audiencia | Propósito |
|---|---|---|
| **Internal Testing** | Equipo dev (máx. 100 usuarios) | Smoke tests, detección temprana |
| **Alpha** | QA + stakeholders (máx. 200) | Validación funcional completa |
| **Beta cerrada** | Usuarios seleccionados (máx. 1,000) | Prueba con datos reales |
| **Beta abierta** | Voluntarios públicos | Carga real, feedback externo |

**Justificación de adopción:** Flutter + GitHub Actions permite generar builds distintos por rama (`develop` → Alpha, `release/*` → Beta). Google Play Console y Apple TestFlight soportan nativamente estos canales sin coste adicional.

---

### 2.3 Rollout Escalonado (Actualización Gradual) ✅ **ESTRATEGIA PRINCIPAL**

**Descripción:** La versión se libera progresivamente a un porcentaje creciente de usuarios en producción:

```
1% → 5% → 10% → 25% → 50% → 100%
```

Cada incremento está separado por un período de monitoreo (mínimo 24h). Si las métricas están dentro de los umbrales definidos, se avanza al siguiente porcentaje.

**Umbrales de alerta que detienen el rollout:**
- Tasa de crash > 1% (Firebase Crashlytics)
- Tiempo de arranque (cold start) > 3s
- Tasa de error de login > 5%
- Calificación promedio cae más de 0.3 puntos

**Justificación de adopción:**
- Google Play Console admite rollout gradual desde el 0.1%.
- Permite detectar problemas de compatibilidad de dispositivo en escenarios reales sin impactar a toda la base de usuarios.
- La arquitectura MVVM del proyecto facilita el monitoreo de estados (isLoading, isSuccess, errorMessage) vía analytics.

---

### 2.4 Canario (Canary Release)

**Descripción:** Una versión "canario" se despliega a un grupo muy pequeño y estático de usuarios en producción real, antes del rollout general.

**En Centrix Mobile se implementa como:**
- El `1%` del rollout gradual actúa como grupo "canario".
- Los usuarios canario son idealmente empleados internos o usuarios beta voluntarios que ya pasaron por TestFlight/Alpha.

**Justificación:** El rollout del 1% actúa como canario implícito. No se requiere infraestructura adicional para este tamaño de proyecto.

---

### 2.5 Feature Flags

**Descripción:** Las funcionalidades se despliegan desactivadas por defecto y se habilitan remotamente para subconjuntos de usuarios sin necesidad de publicar una nueva versión en la tienda.

**Herramienta recomendada:** Firebase Remote Config (gratuito, compatible con Flutter)

**Flags propuestos para Centrix Mobile:**

| Flag | Tipo | Valor Default | Propósito |
|---|---|---|---|
| `login_enabled` | `bool` | `true` | Kill switch de emergencia para login |
| `show_signup_button` | `bool` | `false` | Habilita el botón "Sign Up" (no implementado aún) |
| `api_base_url` | `String` | `prod` | Permite apuntar a staging sin rebuild |
| `max_login_retries` | `int` | `3` | Control de intentos antes de bloquear |
| `enable_biometric_auth` | `bool` | `false` | Feature futura de autenticación biométrica |

**Implementación Flutter (esquema):**

```dart
// lib/core/config/feature_flags.dart
import 'package:firebase_remote_config/firebase_remote_config.dart';

class FeatureFlags {
  static final _rc = FirebaseRemoteConfig.instance;

  static bool get loginEnabled => _rc.getBool('login_enabled');
  static bool get showSignupButton => _rc.getBool('show_signup_button');
  static String get apiBaseUrl => _rc.getString('api_base_url');
}
```

**Justificación:** En la arquitectura actual, el `AuthRepositoryImpl` usa `baseUrl` hardcodeada a `localhost:3000`. Los feature flags permitirán cambiar el endpoint por entorno (dev / staging / prod) sin publicar un update.

---

## 3. Pipeline de Despliegue Completo Recomendado

```
┌───────────────────────────────────────────────────────────────┐
│  PIPELINE CENTRIX MOBILE                                       │
│                                                               │
│  PR / Commit                                                  │
│     │                                                         │
│     ▼                                                         │
│  [CI] Lint + Analyze + Tests + Build (GitHub Actions)        │
│     │                                                         │
│     ▼  (merge a develop)                                      │
│  [CD] Internal Testing (Play / TestFlight)                   │
│     │      <- QA Approval (manual gate) ->                   │
│     ▼  (merge a release/*)                                   │
│  [CD] Alpha -> Beta -> Rollout 1% (Canario)                  │
│     │      <- Monitoreo 24h: Crashlytics + Analytics ->      │
│     ▼  (umbrales OK)                                         │
│  Rollout Gradual: 5% -> 25% -> 50% -> 100%                   │
│     │                                                         │
│  Feature Flags activos en toda la base de usuarios           │
└───────────────────────────────────────────────────────────────┘
```

---

## 4. Ramas de Git y Correspondencia con Canales

| Rama Git | Canal de Distribución | Trigger CI/CD |
|---|---|---|
| `feature/**` | Solo CI (lint + tests) | Push |
| `develop` | Internal Testing | Merge a develop |
| `release/*` | Alpha → Beta | Creación de rama |
| `main` | Producción (Rollout %) | Merge + tag `v*.*.*` |
| `hotfix/**` | Patch en producción | PR a main |

---

## 5. Checklist de Release

Antes de cada incremento del rollout:

- [ ] Crash-free rate ≥ 99%
- [ ] Tiempo medio de login < 2s
- [ ] Tasa de error HTTP 4xx/5xx < 3%
- [ ] 0 issues críticos abiertos en GitHub Issues
- [ ] Feature flags configurados en Firebase Remote Config
- [ ] Notas de release escritas en inglés y español
- [ ] QA firmó el sign-off en el PR de release

---

## 6. Herramientas de Monitoreo Post-Despliegue

| Herramienta | Propósito | Integración |
|---|---|---|
| Firebase Crashlytics | Crash reporting en tiempo real | `firebase_crashlytics` |
| Firebase Analytics | Funnel de conversión de login | `firebase_analytics` |
| Firebase Remote Config | Feature flags y configuración | `firebase_remote_config` |
| Google Play Console | Métricas de rollout Android | Nativo |
| Apple TestFlight / App Store Connect | Métricas iOS | Nativo |
| GitHub Actions | CI/CD pipeline | `.github/workflows/` |

---

## 7. Justificación de la Elección Final

El **rollout escalonado + feature flags + canales de testing** es la estrategia óptima para Centrix Mobile porque:

1. **Reduce el riesgo** al exponer la nueva versión progresivamente, permitiendo revertir con un simple ajuste del porcentaje en Play Console sin rollback de código.
2. **Los feature flags** desacoplan el despliegue del código de la activación de funcionalidades, fundamental mientras el módulo de autenticación es la única feature productiva.
3. **El pipeline CI ya definido** garantiza que ninguna versión con lint warnings, type errors o tests fallidos llegue a producción.
4. **El big bang se descarta** porque la arquitectura actual carece de tests E2E y no hay historial de estabilidad productiva.
5. **La estrategia es escalable**: cuando el proyecto crezca con nuevas features, los feature flags permiten desarrollo en trunk-based sin romper producción.
