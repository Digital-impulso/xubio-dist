@echo off
REM Sella el totem (pantalla tactil, nivel medio): desactiva gestos de borde,
REM Administrador de tareas, centro de notificaciones, tecla Windows y oculta la
REM barra de tareas. Pide permisos de admin. Revertir con RestaurarNormal.bat.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\lockdown-kiosko.ps1"
