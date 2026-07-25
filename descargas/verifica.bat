@echo off
REM Verificador de equipo - Taller "Construye tu Operador de IA"
REM Wellness Total - sabado 15 de agosto, Metepec
echo ============================================
echo  VERIFICADOR DE EQUIPO - TALLER 15 DE AGOSTO
echo ============================================
echo.
echo [1/5] Version de Windows (se necesita Windows 10 u 11):
ver
echo.
echo [2/5] Memoria RAM (recomendado 8 GB, minimo 4 GB):
powershell -NoProfile -Command "'   {0:N1} GB instalados' -f ((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB)"
echo.
echo [3/5] Espacio libre en disco C: (se necesitan 2 GB o mas):
powershell -NoProfile -Command "'   {0:N1} GB libres' -f ((Get-PSDrive C).Free/1GB)"
echo.
echo [4/5] Node.js (se instala en el paso 2 de la guia):
where node >nul 2>nul
if %errorlevel%==0 (
  for /f "delims=" %%v in ('node --version') do echo    OK - Node %%v instalado
) else (
  echo    PENDIENTE - aun no esta instalado. Sigue el paso 2 de la guia.
)
echo.
echo [5/5] Claude Code (se instala en el paso 2 de la guia):
where claude >nul 2>nul
if %errorlevel%==0 (
  for /f "delims=" %%v in ('claude --version 2^>nul') do echo    OK - Claude Code %%v instalado
) else (
  echo    PENDIENTE - aun no esta instalado. Sigue el paso 2 de la guia.
)
echo.
echo ============================================
echo  Tomale una captura (o foto) a esta ventana
echo  y mandala por WhatsApp: +52 1 55 4840 7552
echo  - Si todo dice OK: ese es tu semaforo verde
echo  - Si algo dice PENDIENTE o salio raro: te
echo    ayudamos sin costo a dejarlo listo
echo ============================================
echo.
pause
