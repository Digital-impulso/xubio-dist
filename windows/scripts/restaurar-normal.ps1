<#
.SYNOPSIS
  Revierte lockdown-kiosko.ps1: vuelve la PC a modo normal (gestos táctiles,
  centro de notificaciones, Administrador de tareas, tecla Windows y barra de
  tareas visible). Requiere admin (se auto-eleva).
#>

# --- Auto-elevación a administrador ---
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host '[restaurar] Pidiendo permisos de administrador...' -ForegroundColor Yellow
    Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# --- Mismas claves que el lockdown: borrar el valor = volver al default ---
$claves = @(
    @{ Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EdgeUI';                  Name = 'AllowEdgeSwipe';            Desc = 'Gestos táctiles de borde' },
    @{ Path = 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer';                Name = 'DisableNotificationCenter'; Desc = 'Centro de notificaciones' },
    @{ Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System';   Name = 'DisableTaskMgr';            Desc = 'Administrador de tareas' },
    @{ Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'NoWinKeys';                 Desc = 'Combinaciones con tecla Windows' }
)

foreach ($k in $claves) {
    Remove-ItemProperty -Path $k.Path -Name $k.Name -ErrorAction SilentlyContinue
    Write-Host "[restaurar] OK: $($k.Desc)" -ForegroundColor Green
}

# --- Barra de tareas: visible de nuevo (byte 8 de StuckRects3: 2=off) ---
$sr = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'
if (Test-Path $sr) {
    $bytes = (Get-ItemProperty -Path $sr).Settings
    $bytes[8] = 2
    Set-ItemProperty -Path $sr -Name Settings -Value $bytes
    Write-Host '[restaurar] OK: Barra de tareas visible' -ForegroundColor Green
}

Write-Host '[restaurar] Reiniciando el explorador...' -ForegroundColor Cyan
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Process explorer

Write-Host ''
Write-Host '[restaurar] PC en modo normal. Cerrá sesión o reiniciá para que los gestos de borde vuelvan del todo.' -ForegroundColor Magenta
Read-Host 'Enter para cerrar'
