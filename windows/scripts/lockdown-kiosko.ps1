<#
.SYNOPSIS
  Sella el tótem (nivel "medio", sobre el usuario actual) para una pantalla
  TÁCTIL sin teclado. NO crea usuario nuevo ni reemplaza el shell.

  Desactiva:
    - Gestos táctiles de borde (Task View, Centro de actividades, cambio de app,
      swipe-abajo para cerrar). ← el escape real en una pantalla táctil.
    - Centro de notificaciones.
    - Administrador de tareas (por las dudas: long-press / Ctrl+Alt+Del).
    - Combinaciones con la tecla Windows.
    - Barra de tareas: pasa a oculta automáticamente.

  Reversible con restaurar-normal.ps1. Requiere admin (se auto-eleva).

  OJO: el gesto de borde (AllowEdgeSwipe) puede necesitar CERRAR SESIÓN o
  reiniciar para tomar efecto del todo. El resto aplica al reiniciar explorer.
#>

# --- Auto-elevación a administrador (AllowEdgeSwipe vive en HKLM) ---
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host '[lockdown] Pidiendo permisos de administrador...' -ForegroundColor Yellow
    Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# --- Tabla de ajustes (DWORD). Una fila por bloqueo; sin ifs encadenados. ---
$ajustes = @(
    @{ Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EdgeUI';                       Name = 'AllowEdgeSwipe';           Value = 0; Desc = 'Gestos táctiles de borde' },
    @{ Path = 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer';                     Name = 'DisableNotificationCenter'; Value = 1; Desc = 'Centro de notificaciones' },
    @{ Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System';        Name = 'DisableTaskMgr';            Value = 1; Desc = 'Administrador de tareas' },
    @{ Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer';      Name = 'NoWinKeys';                 Value = 1; Desc = 'Combinaciones con tecla Windows' }
)

foreach ($a in $ajustes) {
    if (-not (Test-Path $a.Path)) { New-Item -Path $a.Path -Force | Out-Null }
    New-ItemProperty -Path $a.Path -Name $a.Name -Value $a.Value -PropertyType DWord -Force | Out-Null
    Write-Host "[lockdown] OK: $($a.Desc)" -ForegroundColor Green
}

# --- Barra de tareas: oculta automáticamente (byte 8 de StuckRects3: 3=on) ---
$sr = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'
if (Test-Path $sr) {
    $bytes = (Get-ItemProperty -Path $sr).Settings
    $bytes[8] = 3
    Set-ItemProperty -Path $sr -Name Settings -Value $bytes
    Write-Host '[lockdown] OK: Barra de tareas oculta automáticamente' -ForegroundColor Green
}

# --- Reiniciar explorer para aplicar barra/notificaciones ---
Write-Host '[lockdown] Reiniciando el explorador...' -ForegroundColor Cyan
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Process explorer

Write-Host ''
Write-Host '════════════════════════════════════════════════════════' -ForegroundColor Magenta
Write-Host '  TÓTEM SELLADO (nivel medio)' -ForegroundColor Magenta
Write-Host '  Para que el bloqueo de gestos de borde tome efecto del' -ForegroundColor Magenta
Write-Host '  todo, CERRÁ SESIÓN o reiniciá la PC.' -ForegroundColor Magenta
Write-Host '  Revertir: RestaurarNormal.bat' -ForegroundColor Magenta
Write-Host '════════════════════════════════════════════════════════' -ForegroundColor Magenta
Read-Host 'Enter para cerrar'
