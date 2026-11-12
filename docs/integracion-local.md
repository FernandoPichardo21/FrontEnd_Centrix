# Integración local de Centrix — 11 de noviembre de 2026

## Flujo recuperado

- Se conserva Flutter con MVVM: `models` consume HTTP, `viewmodels` administra el estado y `views` presenta los datos.
- Crear ticket permite una evidencia opcional JPEG, PNG o MP4 de hasta 5 MB.
- Primero se crea el ticket; con el ID recibido se sube el archivo. Un error de Storage permite reintentar sin duplicar el ticket.
- Detalle del ticket solo consulta y abre evidencias. No presenta controles para cargar archivos.
- Mis tickets usa `/api/tickets/mine`; departamento usa `/api/tickets/department?department_id=...`.
- Pendientes vuelve a estar disponible en `/api/tickets/pending`: administrador ve todos; gerente solo su departamento. Incluye Abierto, En revision y En progreso, excluyendo eliminados.
- La asignación utiliza `PATCH /api/tickets/:id/assign` con `assigned_to` y consulta personal de soporte mediante `/api/users/solvers?department_id=...`.
- El cambio de estado incluye comentario. Es obligatorio para Resuelto, Cerrado y Rechazado. El selector respeta las transiciones del backend.

## Evidencias en el backend

Se recuperaron las rutas autenticadas `POST /api/tickets/:ticketId/evidences` (multipart, campo `file`) y `GET /api/tickets/:ticketId/evidences`.
El backend valida permisos, contenido real y tamaño, sube al bucket y registra `ticket_attachments`.
Si falla la firma o el registro, intenta retirar el objeto subido para evitar archivos sin registro.
Las evidencias anteriores con ruta `tickets/...` y las nuevas con prefijo de bucket siguen siendo consultables.

El bucket se resuelve mediante `SUPABASE_ATTACHMENTS_BUCKET`, después `SUPABASE_STORAGE_BUCKET` y finalmente `evidencias`.
Las claves de Supabase siguen exclusivamente en el backend; no se cambiaron las credenciales del `.env`.
Se conserva `/api/tickets/:id/attachments`, que registra metadatos JSON de un archivo previamente almacenado.

Los permisos nuevos se conservan: gerente opera dentro de su departamento; el creador consulta su ticket y soporte consulta los tickets asignados. La autorización efectiva la decide el servidor.

## Funciones del backend pendientes de incorporar al frontend

| Función | Endpoint y alcance | Trabajo pendiente |
| --- | --- | --- |
| Bandeja de soporte | `GET /api/tickets/assigned`, soporte y administrador | Añadir acceso al dashboard y lista de asignados. |
| Avance por soporte | `PATCH /api/tickets/:id/status`, soporte asignado | Permitir a soporte En revision, En progreso y Resuelto, con comentario obligatorio al resolver. La interfaz actual de gestión sigue siendo para gerente/administrador. |
| Consulta global | `GET /api/tickets`, administrador | Tabla con filtros `status`, `department_id`, `priority` y paginación `page`, `limit`. La respuesta incluye `items` y `pagination`. |
| Eliminación lógica | `DELETE /api/tickets/:id`, administrador | Acción con confirmación y actualización de la lista. El registro se conserva con `deleted_at` y `deleted_by`. |
| Datos de resolución | `GET /api/tickets/:id` incluye `resolutionNotes` y `resolvedAtIso` | Incorporar estos campos al modelo y mostrarlos en el detalle. |

El backend registra historial en los cambios de estado y asignación, pero no expone una ruta independiente para consultar ese historial.
También contiene ejemplos SQL para cambiar roles/departamentos; eso no equivale a endpoints para editar usuarios.
No hay rutas de edición/eliminación de usuarios ni de creación/edición/eliminación de departamentos en el backend revisado.

## Validación realizada

- 19 pruebas del frontend, incluida una conexión HTTP real entre sus ViewModels y Express.
- 271 pruebas del backend, incluidas creación + multipart + consulta, restricciones departamentales, límite de tamaño, limpieza por fallo y rutas antiguas de evidencia.
- Análisis de Dart, ESLint y comprobación de tipos del backend.
- Lectura real en Supabase: bucket privado `evidencias`, JPEG/PNG/MP4 y límite de 5 MB; ambas funciones RPC existen con los parámetros esperados.
- Se leyó un ticket existente y se generó una URL firmada para su evidencia. Las escrituras de las pruebas usaron almacenamiento en memoria.

## Ejecución

Reinicia el backend desde su carpeta con `npm run dev` y el frontend desde su carpeta con `flutter run -d chrome`.
Para navegador, la configuración predeterminada conecta al mismo host en el puerto 3000.
Si ya están en ejecución, detén y vuelve a iniciar ambos para cargar las nuevas rutas y el flujo de creación.

Estos ajustes están en las carpetas locales. No se realizó commit, push ni modificación remota en GitHub.
