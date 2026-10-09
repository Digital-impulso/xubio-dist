@echo off
REM Abre el totem de Xubio en modo kiosco (pantalla completa, sin barra del
REM navegador). Necesita Chrome instalado. Para que arranque solo al prender
REM la PC, poné un acceso directo a este .bat en la carpeta de Inicio
REM (Win+R, shell:startup).
set URL=https://xubio.digitalimpulso.com/?kiosk=1
start "" chrome.exe --kiosk --noerrdialogs --disable-infobars --disable-session-crashed-bubble --disable-translate --overscroll-history-navigation=0 "%URL%"
