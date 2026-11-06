# Centrix — frontend Flutter

La aplicación actual se ejecuta desde la raíz de este repositorio. El código de
`centrix_mobile/` se conserva como proyecto independiente de los avances anteriores
del equipo; tiene su propio `pubspec.yaml`.

## Ejecutar

Se requiere Flutter con Dart 3.13.3 o superior compatible con `pubspec.yaml`.
Desde la raíz:

```sh
flutter pub get
flutter run -d chrome
```

En navegador, la API se busca en el mismo host y puerto 3000. En emulador Android
se utiliza `http://10.0.2.2:3000`. Para usar otro servidor:

```sh
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
```

El backend debe estar ejecutándose y permitir el origen del frontend. Las claves
administrativas de Supabase pertenecen al backend y no se configuran en Flutter.

## Organización MVVM

```text
lib/
  core/          # Configuración, cliente HTTP, rutas, tema y widgets comunes
  features/
    auth/        # Login y sesión en memoria
    dashboard/   # Accesos según el rol
    departments/ # Catálogo de departamentos
    tickets/     # Creación, consultas, detalle, asignación, estado y evidencias
    admin_users/ # Creación de usuarios
  app.dart
  main.dart
```

Cada módulo utiliza `models`, `viewmodels` y `views`. Los modelos consumen la API,
los ViewModels administran los estados y las vistas muestran los datos.

## Evidencias de tickets

Después de crear un ticket, pulsa **Ver ticket y adjuntar evidencia**. En el
detalle puedes seleccionar y adjuntar JPEG, PNG o MP4 de hasta 5 MB. Las imágenes
se muestran en la lista y los archivos se abren mediante URLs temporales. El botón
de actualizar solicita enlaces nuevos.

Esta función necesita que el backend exponga:

```text
POST /api/tickets/:ticketId/evidences   multipart/form-data, campo file
GET  /api/tickets/:ticketId/evidences
```

Ambas rutas requieren `Authorization: Bearer <JWT>`. La API administra el bucket
`evidencias` y la tabla `ticket_attachments`. Este repositorio contiene el frontend;
el backend debe tener esas rutas desplegadas para utilizar la carga.

## Verificación

```sh
flutter analyze
flutter test
```
