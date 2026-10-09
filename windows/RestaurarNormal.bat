@echo off
REM Revierte el sellado del totem: vuelve la PC a modo normal (gestos, barra de
REM tareas, Administrador de tareas, etc.). Pide permisos de admin.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\restaurar-normal.ps1"
