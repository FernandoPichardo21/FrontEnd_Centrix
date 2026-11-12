# Centrix — frontend Flutter

La aplicación se ejecuta desde la raíz de este repositorio. El proyecto anterior
`centrix_mobile/` se retiró; se puede consultar en el historial de Git.

## Ejecutar

Se requiere Flutter con Dart 3.13.3 o superior compatible con `pubspec.yaml`.
El CI utiliza Flutter 3.47.3 con Dart 3.13.3. Utiliza esa versión para reproducir
las verificaciones; una actualización de Flutter debe validarse antes de cambiarla.
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
    manager/     # Prototipo visual de finanzas para Gerente
  app.dart
  main.dart
```

Cada módulo utiliza `models`, `viewmodels` y `views`. Los modelos consumen la API,
los ViewModels administran los estados y las vistas muestran los datos.

## Evidencias de tickets

En **Crear ticket**, selecciona opcionalmente un JPEG, PNG o MP4 de hasta 5 MB.
El ViewModel crea el ticket y después adjunta el archivo usando el ID recibido.
Si falla la carga, puedes reintentar la evidencia sin volver a crear el ticket.
El detalle permite solamente consultar y abrir evidencias mediante URLs temporales.
El botón de actualizar solicita enlaces nuevos.

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

El workflow `ci_mobile.yml` verifica esta aplicación desde la raíz y se ejecuta
también al publicar cambios en `sprint`. Fija Flutter 3.47.3 para evitar cambios
automáticos de SDK y mantiene el análisis estricto, el formato y las pruebas.

La prueba HTTP entre ambos proyectos se activa indicando la carpeta del backend:

```powershell
$env:CENTRIX_BACKEND_DIR = 'C:\ruta\centrix-backend-actual'
# Si node no está en PATH: $env:NODE_BINARY = 'C:\ruta\node.exe'
flutter test test/backend_contract_test.dart
```

Esa prueba inicia Express en un puerto local temporal y usa base de datos y Storage
en memoria. Verifica los contratos sin escribir en Supabase.
Consulta [el estado local y las funciones pendientes](docs/integracion-local.md).

## Pantallas visuales de Gerente

Desde el login, abre **Vista previa · Gerente** para explorar aprobaciones,
presupuesto, solicitudes del departamento y reportes. Usan datos de ejemplo y
cambios temporales, sin conectarse al backend. Conservan la organización MVVM
y el diseño glass de Centrix. Más detalles en [Gerente visual](docs/gerente-visual.md).

Toda la aplicación comparte el [tema oscuro de Centrix](docs/tema-global.md), con
acentos esmeralda/neón y superficies glass. El dashboard conserva sus accesos
compactos y navegación inferior: [Dashboard oscuro](docs/dashboard-oscuro.md).
