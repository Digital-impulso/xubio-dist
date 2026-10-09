# Xubio Tótem — distribución

Wrapper nativo del [tótem de Xubio](https://xubio.digitalimpulso.com) para
Android y Windows, en modo kiosco. El tótem en sí corre 100% en la nube
(Vercel + Turso) — esto es solo pantalla completa + bloqueo del sistema
operativo encima de esa misma página, que ya es offline-first (si se corta la
red a mitad de una partida, la guarda y la sincroniza sola al volver).

**Descargar la última versión:** [Releases](../../releases/latest) — cada
push a `main` genera una versión nueva y sola, con el `.apk` de Android y el
`.zip` de Windows.

## Android

1. Bajá `XubioTotem.apk` del último release.
2. Copialo a la tablet (USB, WhatsApp, Drive, pendrive) y abrilo — aceptar
   "instalar apps de origen desconocido" si lo pide.
3. Al abrir por primera vez, Android pregunta si querés **anclar la
   pantalla** (screen pinning): aceptar. Con eso ya no se sale con Atrás ni
   con Recientes.
4. (Opcional, para un kiosco de verdad) *Ajustes → Apps → Apps
   predeterminadas → App de inicio* → **Xubio Tótem**. Ahora Home vuelve al
   tótem y arranca solo al prender la tablet.
5. (Opcional, bloqueo total) Con una tablet **sin cuentas de Google
   agregadas** y depuración USB:
   ```
   adb install -r XubioTotem.apk
   adb shell dpm set-device-owner com.digitalimpulso.xubio.totem/.KioscoAdminReceiver
   ```
   Deshacer: `adb shell dpm remove-active-admin com.digitalimpulso.xubio.totem/.KioscoAdminReceiver`

**Salir del kiosco (staff):** 5 toques rápidos en la esquina superior
izquierda → confirmar.

El APK firma con la clave de **debug** (fija, la misma en cualquier
instalación del SDK de Android) — alcanza para sideload y para que las
actualizaciones instalen limpio sobre la versión anterior. El día que haga
falta una keystore de release propia (por ejemplo para Play Store), hay que
generarla con `keytool`, subir `ANDROID_KEYSTORE_BASE64` /
`ANDROID_KEYSTORE_PASSWORD` / `ANDROID_KEY_ALIAS` / `ANDROID_KEY_PASSWORD`
como Secrets del repo, y cambiar `android/app/build.gradle` para firmar
`release` con eso en vez de debug.

## Windows

Bajá y descomprimí `XubioTotem-Windows.zip` del último release — trae
`IniciarTotem.bat` (abre Chrome en kiosco) y los scripts para sellar/restaurar
la PC. Instrucciones completas en el `README.md` de esa carpeta.

## Código

- `android/` — proyecto Gradle plano (sin Capacitor/Node): un `WebView`
  (`androidx.webkit`) cargando `xubio.digitalimpulso.com/?kiosk=1`, con el
  blindaje de kiosco nativo en `MainActivity.java` (pantalla inmersiva,
  anclaje, salida del staff). Nada del contenido web se empaqueta acá, así
  que un cambio en el tótem no necesita un APK nuevo — solo lo necesita si
  cambia el blindaje nativo en sí.
- `windows/` — los `.bat`/`.ps1` de kiosco, sin nada que instalar (el tótem no
  tiene backend local).
- `.github/workflows/build.yml` — en cada push a `main`, compila el APK,
  empaqueta `windows/`, y publica un [Release](../../releases) nuevo con los
  dos archivos.
