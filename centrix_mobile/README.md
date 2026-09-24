# Centrix Mobile

Frontend de Centrix desarrollado con Flutter. Incluye autenticación mediante el backend, redirección por roles, dashboards empresariales y administración de usuarios.

## Ejecución

```powershell
flutter pub get
flutter run -d chrome
```

Para ejecutar en un emulador Android:

```powershell
flutter run -d emulator-5554
```

El backend debe estar disponible en el puerto `3000`. La aplicación utiliza automáticamente `localhost` en web y `10.0.2.2` en el emulador Android.

## Documentación

La explicación completa de la arquitectura, los flujos, SOLID y el guion sugerido para la exposición se encuentra en [docs/GUIA_FRONTEND.md](docs/GUIA_FRONTEND.md).
