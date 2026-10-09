# Tótem Xubio — Windows

Tres `.bat`, se corren en este orden:

1. **`IniciarTotem.bat`** — abre Chrome en modo kiosco apuntando al tótem
   (`xubio.digitalimpulso.com`). Para que arranque solo al prender la PC,
   ponele un acceso directo en la carpeta de Inicio (`Win+R` → `shell:startup`).
2. **`SellarKiosco.bat`** — sella la PC: desactiva gestos de borde, Administrador
   de tareas, centro de notificaciones, tecla Windows, y oculta la barra de
   tareas. Pide permisos de administrador. Para que el bloqueo de gestos tome
   efecto del todo, cerrá sesión o reiniciá después de correrlo.
3. **`RestaurarNormal.bat`** — revierte todo lo anterior, por si hay que volver
   a usar la PC normal.

No hace falta instalar nada más — el tótem corre 100% en la nube (Vercel +
Turso), así que esta PC no necesita backend local ni base de datos propia. Si
se corta la conexión a mitad de una partida, el tótem la guarda en una cola
local y la sincroniza solo al volver la red (no hace falta hacer nada para eso
acá, ya viene así en la página).
