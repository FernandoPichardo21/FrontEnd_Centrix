# Alta de usuarios: rol y departamento

El formulario conserva MVVM. `UserModel` consulta `GET /api/admin/roles`, `DepartmentModel` consulta el catálogo de departamentos y `CreateUserViewModel` administra la selección y las validaciones.

## Campos

| Campo | Regla |
| --- | --- |
| Correo | Obligatorio, formato de correo. |
| Nombre y apellido paterno | Obligatorios. |
| Apellido materno | Opcional. |
| Teléfono | Opcional, hasta 30 caracteres. |
| Rol | Se elige del catálogo del backend. La selección inicial es Colaborador, nunca Administrador. |
| Departamento | Obligatorio para Colaborador, Gerente y Soporte técnico; opcional para Administrador. |
| Contraseña | Obligatoria, mínimo 8 caracteres. |
| Confirmación | Debe coincidir; no se envía al backend. |

Los roles actuales son `colaborador`, `gerente`, `soporte_tecnico` y `administrador`. El rol correcto para las pantallas visuales de supervisión es **Gerente**, no Supervisor.

## Contrato del backend

Solo un administrador puede consultar los roles o dar de alta cuentas.

```http
GET /api/admin/roles
Authorization: Bearer JWT_ADMIN
```

```json
{
  "email": "persona@empresa.com",
  "password": "una-clave-de-8-o-mas-caracteres",
  "nombre": "Ana",
  "apellido_pat": "López",
  "role": "gerente",
  "department_id": "UUID_DEL_DEPARTAMENTO_EXISTENTE"
}
```

El JSON se envía mediante `POST /api/admin/users`. El servidor valida el rol por descripción y la existencia del departamento antes de crear la cuenta de Auth. En el catálogo actual el ID 1 significa Administrador, el ID 2 Gerente y el ID 3 Colaborador; el cliente no envía ni asume estos IDs.

Al guardar el perfil nuevo se retiran los roles automáticos que pueda haber recibido esa cuenta y se asigna únicamente el seleccionado. Si falla el guardado, se intenta retirar el perfil y la cuenta de Auth creados durante la operación. No se modifican cuentas anteriores.

El formulario bloquea el envío si no puede cargar los catálogos. Si el backend anterior devuelve 404 en `/api/admin/roles`, pide actualizarlo y reiniciarlo; así evita enviar una selección que el servidor antiguo ignoraría.

## Aplicar los cambios

Reinicia el backend desde `centrix-backend-actual` y realiza un hot restart de Flutter (`R` mayúscula). No se requieren cambios de tablas o claves de Supabase. Las pruebas de creación usan datos en memoria, no crean cuentas reales en el proyecto.
