# Dashboard oscuro de Centrix

El dashboard conserva MVVM: los modelos existentes consultan la API, `DashboardViewModel` prepara los datos y la vista presenta los componentes. Su paleta oscura se comparte ahora con todas las vistas mediante el tema global de Centrix.

- AppBar con identidad de Centrix, avisos de tickets e iniciales del usuario autenticado.
- Bienvenida con nombre, correo y rol reales; no se fijaron datos de una persona en la aplicación.
- Tarjeta principal para Crear ticket, o Mis tickets cuando el rol no puede crear.
- Cuatro accesos compactos por rol. Administrador: Mis tickets, Pendientes, Departamentos y Crear usuario. Gerente: sus cuatro pantallas visuales. Los demás accesos siguen disponibles en **Ver todos** y en **Tickets**.
- Actividad horizontal con tickets que el usuario tiene permiso de consultar.
- Barra inferior de Inicio, Tickets, Mensajes y Perfil. Mensajes se identifica como vista previa; Perfil muestra los datos de sesión y permite cerrarla.

## Datos y métricas

El dashboard solo reutiliza consultas existentes de Mis tickets, Pendientes y Departamentos. Los contadores no están inventados: se muestran después de consultar, o con un guion cuando no hay datos disponibles. El indicador de Resolución representa la proporción de los tickets propios que están resueltos o cerrados; no es una calificación de rendimiento del empleado.

El botón de actualización y el gesto de arrastrar hacia abajo vuelven a consultar la actividad. Los avisos se derivan de los tickets pendientes, no de un servicio de notificaciones push.

Las pantallas financieras de Gerente siguen siendo demostraciones visuales con la etiqueta Demo. No se añadieron endpoints ni cambios de base de datos para el dashboard.

## Adaptación y pruebas

La cuadrícula usa dos columnas en móvil y cuatro en escritorio. Se comprobó que el dashboard de Administrador cabe a 390 × 844 sin desplazamiento vertical; en pantallas pequeñas o con textos ampliados se conserva el desplazamiento necesario para mantener el acceso al contenido.

Las capturas de verificación se generan con datos de prueba y no corresponden a registros creados en Supabase. La prueba verifica los contadores, el porcentaje de resolución, la navegación inferior y el acceso a módulos que no aparecen en la cuadrícula principal.

Para cargar el cambio, realiza un hot restart de Flutter con **R mayúscula**.
