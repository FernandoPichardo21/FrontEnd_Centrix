# Guía del frontend de Centrix

## 1. Objetivo del frontend

El frontend de Centrix es una aplicación Flutter que permite:

- iniciar sesión mediante el backend;
- identificar el rol del usuario autenticado;
- mostrar un dashboard distinto para colaborador, gerente o administrador;
- permitir al administrador consultar y registrar usuarios;
- cerrar la sesión y regresar de forma segura al login;
- funcionar tanto en navegador web como en un emulador Android.

El frontend no consulta Supabase directamente. Toda operación de autenticación y administración pasa por la API del backend.

## 2. Tecnologías principales

| Tecnología | Responsabilidad |
|---|---|
| Flutter | Construcción de la interfaz multiplataforma |
| Dart | Lenguaje de programación |
| Provider | Inyección de dependencias y actualización de la interfaz |
| ChangeNotifier | Manejo del estado de cada módulo |
| HTTP | Comunicación con la API REST |
| Material Design | Componentes visuales y navegación |

## 3. Organización del proyecto

```text
lib/
├── config/
│   └── api_config.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── auth_repository.dart
│   │   │   └── auth_repository_impl.dart
│   │   ├── view/
│   │   └── viewmodel/
│   ├── dashboard/
│   │   ├── domain/
│   │   └── view/
│   └── admin/users/
│       ├── data/
│       ├── domain/
│       ├── view/
│       └── viewmodel/
└── main.dart
```

La aplicación está organizada por funcionalidades. Cada funcionalidad contiene solamente las capas que necesita.

## 4. Arquitectura utilizada

Se utiliza una separación similar a MVVM combinada con el patrón Repository:

```text
Vista → ViewModel → Repository → Backend
  ↑          │
  └──────────┘ notifica cambios con ChangeNotifier
```

### Vista

Presenta los datos y recibe las acciones del usuario. No contiene código para hacer peticiones HTTP.

Ejemplos:

- `LoginScreen`
- `AdminUsersScreen`
- `DashboardShell`

### ViewModel

Mantiene el estado de la pantalla y coordina las operaciones.

Ejemplos de estado:

- `isLoading`
- `isSubmitting`
- `errorMessage`
- `authenticatedUser`
- `users`
- `token`

### Repository

Define y ejecuta el acceso a datos. La vista no necesita conocer la dirección del servidor ni el formato exacto del JSON.

Ejemplos:

- `AuthRepository`
- `AuthRepositoryImpl`
- `AdminUserRepository`
- `HttpAdminUserRepository`

### Modelos de dominio y transferencia

Representan datos con tipos de Dart en lugar de manipular mapas JSON por toda la aplicación.

Ejemplos:

- `LoginRequest`
- `LoginResponse`
- `UserModel`
- `AdminUser`
- `CreateUserRequest`

## 5. Punto de entrada e inyección de dependencias

El archivo `main.dart` realiza tres tareas:

1. crea el repositorio de autenticación;
2. registra `LoginViewModel` mediante `ChangeNotifierProvider`;
3. inicia `CentrixApp`.

El provider se coloca por encima de `MaterialApp`, por lo que el estado de autenticación está disponible para el login y los dashboards.

La ruta `/login` permite regresar al inicio de sesión cuando el usuario cierra su sesión.

## 6. Configuración de la API

`ApiConfig` decide la dirección base del backend:

| Plataforma | URL predeterminada |
|---|---|
| Web y escritorio | `http://localhost:3000` |
| Emulador Android | `http://10.0.2.2:3000` |

En un emulador Android, `localhost` representa al propio dispositivo virtual. La dirección especial `10.0.2.2` representa a la computadora anfitriona.

También se puede proporcionar otra dirección al ejecutar Flutter:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000
```

Esto es útil para un teléfono físico conectado a la misma red local.

## 7. Flujo de inicio de sesión

```text
Usuario escribe correo y contraseña
              ↓
LoginScreen llama a LoginViewModel.login()
              ↓
AuthRepositoryImpl envía POST /api/auth/login
              ↓
LoginResponse convierte el JSON a objetos Dart
              ↓
LoginViewModel guarda usuario y token
              ↓
DashboardRouter selecciona pantalla según el rol
```

### Responsabilidades importantes

- `LoginScreen` solamente recoge los datos y presenta el resultado.
- `LoginViewModel` controla carga, error, usuario y token.
- `AuthRepositoryImpl` conoce HTTP y el endpoint.
- `DashboardRouter` transforma el rol recibido en una pantalla concreta.

El token recibido se conserva en memoria dentro de `LoginViewModel`. Se utiliza como `Bearer token` para las operaciones administrativas.

## 8. Redirección por roles

`UserRole.fromBackend()` normaliza el texto recibido y reconoce:

- `colaborador`;
- `gerente`;
- `administrador` o `admin`;
- cualquier otro valor como rol desconocido.

`DashboardRouter` aplica la decisión:

```text
colaborador    → CollaboratorDashboardScreen
gerente        → ManagerDashboardScreen
administrador  → AdminDashboardScreen
desconocido    → UnsupportedRoleScreen
```

Cada pantalla proporciona sus acciones a `DashboardShell`. Así se reutiliza la misma estructura visual sin duplicar el encabezado, la tarjeta de bienvenida ni el menú de cuenta.

## 9. Dashboard y cierre de sesión

`DashboardShell` es un componente reutilizable que recibe:

- nombre y correo del usuario;
- etiqueta del rol;
- acciones disponibles;
- función para cerrar la sesión.

Al pulsar el avatar aparece un menú con la información de la cuenta y la opción **Cerrar sesión**.

El cierre de sesión:

1. elimina el usuario y token de `LoginViewModel`;
2. restablece los estados de carga y error;
3. navega a `/login`;
4. elimina las rutas anteriores mediante `pushNamedAndRemoveUntil`.

Eliminar el historial impide regresar al dashboard con el botón Atrás después de cerrar sesión.

## 10. Administración de usuarios

### Creación del módulo

`AdminUsersModule` construye las dependencias específicas de esta funcionalidad:

```text
HTTP Client + URL + token
            ↓
HttpAdminUserRepository
            ↓
AdminUsersViewModel
            ↓
AdminUsersScreen
```

Cuando se crea el ViewModel se ejecuta `loadUsers()`, por lo que la primera consulta comienza automáticamente.

### Consulta de usuarios

`HttpAdminUserRepository.fetchAll()` envía:

```http
GET /api/admin/users
Authorization: Bearer <token>
```

La respuesta se convierte en una lista de objetos `AdminUser`. La pantalla contempla cuatro estados:

- cargando;
- error con botón para reintentar;
- lista vacía;
- directorio con usuarios.

En escritorio se utiliza una tabla. En móvil se utilizan tarjetas para evitar desbordamientos horizontales.

### Registro de un usuario

El botón **Agregar usuario** abre un diálogo con el formulario. El frontend valida:

- campos obligatorios;
- formato básico del correo;
- contraseña de al menos seis caracteres.

Después construye un `CreateUserRequest` y envía:

```http
POST /api/admin/users
Authorization: Bearer <token>
Content-Type: application/json
```

Si la creación termina correctamente:

1. el ViewModel vuelve a consultar la lista;
2. el diálogo se cierra;
3. aparece un mensaje de confirmación;
4. el nuevo registro se muestra sin reiniciar la aplicación.

## 11. Diseño adaptable

La interfaz utiliza `LayoutBuilder` y restricciones de ancho.

- En pantallas amplias, los elementos se distribuyen en columnas y tablas.
- En móvil, se apilan verticalmente.
- Los nombres largos admiten dos líneas y puntos suspensivos.
- El rol se coloca debajo del nombre para no competir por el ancho.
- El formulario cambia de dos columnas a una columna según el espacio disponible.

Este enfoque evita utilizar tamaños específicos para un solo modelo de teléfono.

## 12. Aplicación de SOLID

### Responsabilidad única

Cada clase tiene una tarea principal: la vista presenta, el ViewModel administra estado y el repositorio obtiene datos.

### Abierto/cerrado

Se pueden agregar implementaciones nuevas de los repositorios sin modificar las pantallas. Por ejemplo, un repositorio de pruebas puede sustituir al repositorio HTTP.

### Sustitución de Liskov

Cualquier implementación de `AuthRepository` o `AdminUserRepository` debe poder utilizarse donde se espera su interfaz.

### Segregación de interfaces

Las interfaces exponen únicamente las operaciones necesarias para su funcionalidad, como `login`, `fetchAll` y `create`.

### Inversión de dependencias

Los ViewModels dependen de abstracciones (`AuthRepository` y `AdminUserRepository`) y no directamente del paquete HTTP.

## 13. Manejo de errores

Los repositorios convierten problemas técnicos en mensajes entendibles:

- backend no disponible;
- respuesta JSON incorrecta;
- error HTTP;
- token sin permisos;
- credenciales inválidas.

Los ViewModels guardan esos mensajes y notifican a las vistas. De esta manera la capa visual no necesita interpretar códigos HTTP.

## 14. Pruebas

Las pruebas del frontend verifican principalmente:

- redirección al dashboard correspondiente;
- lectura del usuario y token de la respuesta de login;
- transformación del formulario al contrato del backend;
- encabezado `Authorization` en la creación;
- mensajes del ViewModel al completar una operación.

Los repositorios abstractos permiten usar implementaciones falsas durante las pruebas sin depender de un servidor real.

## 15. Guion breve para la exposición

Puedes explicar el proyecto en este orden:

1. **Problema:** se necesita una aplicación con acceso por roles y administración de usuarios.
2. **Solución:** Flutter consume una API REST y presenta una interfaz adaptada al rol.
3. **Arquitectura:** vista, ViewModel, repositorio y backend están separados.
4. **Login:** el backend valida las credenciales y devuelve usuario, rol y token.
5. **Roles:** `DashboardRouter` decide qué dashboard presentar.
6. **Administración:** el administrador consulta usuarios y abre un formulario para registrar uno nuevo.
7. **Seguridad:** las peticiones administrativas llevan un token y el logout borra la sesión y el historial.
8. **Adaptabilidad:** la misma aplicación funciona en web y Android con diseños responsive.
9. **Mantenibilidad:** el uso de interfaces y responsabilidades separadas permite agregar historias futuras sin reescribir todo.

## 16. Demostración recomendada

1. Iniciar el backend.
2. Abrir la aplicación.
3. Iniciar sesión como administrador.
4. Mostrar el dashboard y explicar la redirección por rol.
5. Abrir **Usuarios y roles**.
6. Mostrar la carga del directorio.
7. Registrar un usuario y comprobar la actualización automática.
8. Abrir el menú del avatar.
9. Cerrar sesión y demostrar que no se puede volver al dashboard con Atrás.

## 17. Preguntas que podrían hacerte

**¿Por qué no se conecta Flutter directamente con Supabase?**

Para centralizar reglas, autorización y lógica de negocio en el backend. El frontend no necesita secretos ni conocimiento de la base de datos.

**¿Por qué se utiliza Provider?**

Permite compartir ViewModels y reconstruir solamente los widgets que dependen de su estado.

**¿Por qué existen interfaces de repositorio?**

Desacoplan los ViewModels de HTTP, facilitan las pruebas y permiten sustituir la fuente de datos.

**¿Por qué Android usa `10.0.2.2`?**

Porque `localhost` dentro del emulador apunta al propio emulador. `10.0.2.2` es el acceso especial hacia la computadora anfitriona.

**¿Dónde se guarda el token?**

Actualmente se mantiene en memoria dentro de `LoginViewModel`. Al cerrar la aplicación o cerrar sesión se pierde. Una historia futura podría agregar almacenamiento seguro si se necesita conservar la sesión.

**¿Qué ocurre con un rol desconocido?**

Se muestra una pantalla segura de rol no reconocido en lugar de conceder acceso a un dashboard incorrecto.
