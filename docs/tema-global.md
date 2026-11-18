# Diseño oscuro compartido

Toda la aplicación usa `CentrixTheme.dark`, definido en `lib/core/theme/centrix_theme.dart`.
La paleta combina fondo casi negro, superficies verdes oscuras, texto menta, acentos neón y estados ámbar/rosa.

El estilo se aplica a login, dashboard, catálogo de departamentos, creación/listados/detalle de tickets,
formularios de usuarios y las cuatro pantallas visuales de Gerente. También cubre diálogos, mensajes de error,
confirmaciones, menús desplegables, selectores, tablas, botones e indicadores.

- `CentrixGlass` comparte los fondos translúcidos oscuros, desenfoque, contornos y sombras.
- `CentrixPageHeader` mantiene la identidad en las cabeceras.
- Los componentes del dashboard reutilizan la misma paleta y tema global.
- Las vistas de Gerente conservan las etiquetas de datos de ejemplo.
- Los colores de aprobado, pendiente y rechazado siguen siendo distintos y legibles.

No se cambiaron modelos de negocio, permisos, llamadas a la API, backend ni datos de Supabase.
La verificación visual utiliza datos simulados en móvil y escritorio. Los formularios y las listas mantienen
el desplazamiento necesario para acceder a toda la información.

Para ver la actualización completa, realiza un hot restart con **R mayúscula** desde la terminal de Flutter.
