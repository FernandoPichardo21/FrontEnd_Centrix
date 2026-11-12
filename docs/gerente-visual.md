# Gerente: pantallas visuales

El backend se conserva con la versión actual de tickets y evidencias. No se integró el módulo de finanzas de `dev` ni se modificó Supabase.

## Cómo entrar

1. Realiza un hot restart de Flutter con `R` mayúscula, o detén y vuelve a iniciar `flutter run -d chrome`.
2. En el login, pulsa **Vista previa · Gerente**. No requiere iniciar sesión.
3. Usa la navegación lateral; en móvil se abre desde el botón de menú.
4. El botón de salida vuelve al login o al inicio de la sesión que ya estuviera abierta.

Los enlaces `/preview/gerente/...` contienen únicamente datos ficticios. Las rutas `/gerente/...` permanecen protegidas para el rol `gerente`, con los cuatro accesos correspondientes en su dashboard junto con sus módulos de tickets. El backend ya reconoce Gerente; las pantallas de presupuesto, solicitudes financieras y reportes siguen siendo visuales.

## Pantallas

| Pantalla | Contenido e interacciones visuales |
| --- | --- |
| Aprobaciones | Bandeja de pendientes, monto, solicitante, categoría, justificación y documento de ejemplo. Aprobar requiere confirmación; rechazar pide un motivo. |
| Presupuesto | Presupuesto del mes, monto ejercido y disponible, pendientes por autorizar, indicador circular y distribución por categorías. El diálogo permite ajustar la distribución. |
| Solicitudes del departamento | Historial de Operaciones, búsqueda por folio/concepto/persona, filtros por estado y categoría, tabla en escritorio, tarjetas en móvil y detalle de solo consulta. |
| Reportes | Periodos de septiembre, octubre y noviembre de 2026, indicadores, distribución de estados, montos por categoría y vista previa del reporte. |

Las decisiones se reflejan entre pantallas durante la misma visita. Las aprobaciones descuentan el monto de la categoría; los rechazos no consumen presupuesto. El presupuesto no puede reducirse por debajo de lo ejercido. El botón de restablecer recupera los datos originales de ejemplo.

Todo es una demostración visual en memoria: no hay solicitudes HTTP, escritura de archivos de usuario, carga de comprobantes, descarga de reportes ni persistencia de las decisiones. La documentación PDF mostrada es una representación visual, no un archivo real.

## Estructura MVVM

```text
lib/features/manager/
  models/
    manager_request.dart       # Solicitud, estados, categorías y secciones
    manager_demo_model.dart    # Datos ficticios del prototipo
  viewmodels/
    manager_view_model.dart    # Filtros, selección, decisiones y cálculos locales
  views/
    manager_workspace_view.dart
    manager_approvals_view.dart
    manager_budget_view.dart
    manager_requests_view.dart
    manager_reports_view.dart
    widgets/manager_widgets.dart
```

Las vistas presentan datos del ViewModel y emiten acciones. El modelo no depende de Dio, Supabase, almacenamiento ni del backend. Cuando se implemente el backend, se podrá reemplazar el origen de datos y conectar las acciones manteniendo la organización MVVM.

## Validación

Se verificaron los permisos del dashboard, las decisiones temporales, la navegación de las cuatro pantallas, el presupuesto, la búsqueda y el cambio de periodo. También se revisaron capturas a 1440 px de escritorio y 390 px de móvil. La suite existente de login, tickets y evidencias se conserva.
