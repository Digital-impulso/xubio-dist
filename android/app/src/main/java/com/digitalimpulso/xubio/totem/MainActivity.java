package com.digitalimpulso.xubio.totem;

import android.app.ActivityManager;
import android.app.AlertDialog;
import android.app.admin.DevicePolicyManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.WindowManager;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;

/**
 * Tótem Xubio en modo kiosco. La "app" es un WebView apuntando al tótem real
 * (xubio.digitalimpulso.com) — nada del contenido se empaqueta acá, así que
 * cualquier cambio en el tótem web (incluida la cola offline-first que ya
 * trae esa página) se ve directo, sin tener que generar un APK nuevo. Este
 * APK solo necesita reconstruirse si cambia el blindaje nativo en sí.
 *
 * El blindaje (pantalla inmersiva, anclaje, device owner) está adaptado del
 * mismo mecanismo ya probado en el APK de Droguerías del Sud
 * (frontend-totem/android/.../MainActivity.java), reescrito sin Capacitor —
 * acá no hace falta: es WebView + Android puro, nada de JS bridge.
 *
 *  - Pantalla siempre encendida y sin bloqueo.
 *  - Inmersivo "sticky": sin barras del sistema; si alguien las saca con un
 *    gesto, vuelven a esconderse solas.
 *  - Atrás anulado: nunca sale de la app por ahí.
 *  - Lock task: con la app como DEVICE OWNER (ver README) el anclaje es
 *    total. Sin eso, cae al "anclaje de pantalla" normal de Android.
 *  - 5 toques rápidos en la esquina superior-izquierda + confirmar = salida
 *    del staff.
 */
public class MainActivity extends AppCompatActivity {

  private static final String URL = "https://xubio.digitalimpulso.com/?kiosk=1";
  private static final int VENTANA_TOQUES_MS = 2000;

  private final long[] toques = new long[5];

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    getWindow().addFlags(
      WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
        | WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
        | WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        | WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
    );

    WebView web = new WebView(this);
    WebSettings s = web.getSettings();
    s.setJavaScriptEnabled(true);
    s.setDomStorageEnabled(true);
    s.setDatabaseEnabled(true);
    s.setMediaPlaybackRequiresUserGesture(false);
    s.setCacheMode(WebSettings.LOAD_DEFAULT);
    web.setWebViewClient(new WebViewClient());
    web.setWebChromeClient(new WebChromeClient());
    web.loadUrl(URL);
    setContentView(web);

    ocultarBarras();
  }

  @Override
  public void onResume() {
    super.onResume();
    ocultarBarras();
    anclar();
  }

  @Override
  public void onWindowFocusChanged(boolean hasFocus) {
    super.onWindowFocusChanged(hasFocus);
    if (hasFocus) ocultarBarras();
  }

  /** El botón atrás no hace nada: la navegación es solo la de la pantalla. */
  @Override
  public void onBackPressed() {
    // intencionalmente vacío
  }

  /** Detecta el gesto de salida del staff en todo el árbol de vistas (la
      esquina superior-izquierda, 100x100dp) sin tocar nada del WebView. */
  @Override
  public boolean dispatchTouchEvent(MotionEvent ev) {
    if (ev.getAction() == MotionEvent.ACTION_DOWN) {
      float densidad = getResources().getDisplayMetrics().density;
      if (ev.getRawX() < 100 * densidad && ev.getRawY() < 100 * densidad) {
        registrarToqueSalida();
      }
    }
    return super.dispatchTouchEvent(ev);
  }

  private void registrarToqueSalida() {
    System.arraycopy(toques, 1, toques, 0, toques.length - 1);
    toques[toques.length - 1] = System.currentTimeMillis();
    if (toques[0] != 0 && toques[toques.length - 1] - toques[0] < VENTANA_TOQUES_MS) {
      java.util.Arrays.fill(toques, 0);
      confirmarSalida();
    }
  }

  private void confirmarSalida() {
    new AlertDialog.Builder(this)
      .setTitle("¿Salir del modo kiosco?")
      .setPositiveButton("Salir", (d, w) -> {
        try { stopLockTask(); } catch (Exception ignored) {}
        finishAffinity();
      })
      .setNegativeButton("Cancelar", null)
      .show();
  }

  private void ocultarBarras() {
    WindowCompat.setDecorFitsSystemWindows(getWindow(), false);
    WindowInsetsControllerCompat c = WindowCompat.getInsetsController(getWindow(), getWindow().getDecorView());
    if (c == null) return;
    c.hide(WindowInsetsCompat.Type.systemBars());
    c.setSystemBarsBehavior(WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);
  }

  private void anclar() {
    try {
      ActivityManager am = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
      if (am.getLockTaskModeState() != ActivityManager.LOCK_TASK_MODE_NONE) return;

      DevicePolicyManager dpm = (DevicePolicyManager) getSystemService(Context.DEVICE_POLICY_SERVICE);
      if (dpm.isDeviceOwnerApp(getPackageName())) {
        ComponentName admin = new ComponentName(this, KioscoAdminReceiver.class);
        dpm.setLockTaskPackages(admin, new String[] { getPackageName() });
        IntentFilter home = new IntentFilter(Intent.ACTION_MAIN);
        home.addCategory(Intent.CATEGORY_HOME);
        home.addCategory(Intent.CATEGORY_DEFAULT);
        dpm.addPersistentPreferredActivity(admin, home, new ComponentName(this, MainActivity.class));
        dpm.setStatusBarDisabled(admin, true);
        dpm.setKeyguardDisabled(admin, true);
      }
      startLockTask();
    } catch (Exception ignored) {
      // Sin permisos para anclar: seguimos igual, el resto del blindaje aplica.
    }
  }
}
