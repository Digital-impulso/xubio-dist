package com.digitalimpulso.xubio.totem;

import android.app.admin.DeviceAdminReceiver;

/**
 * Receptor de administración de dispositivo. Existe para poder nombrar la app
 * como DEVICE OWNER (kiosco total — ver README del repo):
 *
 *   adb shell dpm set-device-owner com.digitalimpulso.xubio.totem/.KioscoAdminReceiver
 */
public class KioscoAdminReceiver extends DeviceAdminReceiver {}
