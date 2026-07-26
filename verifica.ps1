# Verificador de equipo - Taller "Construye tu Operador de IA"
# Wellness Total - sabado 15 de agosto, Metepec
# Uso:  irm https://taller.wellnesstotal.tech/verifica.ps1 | iex
# NOTA: sin acentos a proposito (encoding seguro al ejecutar desde memoria)

$ErrorActionPreference = "SilentlyContinue"
$alertas = 0
$bloqueos = 0

function Linea { Write-Host ("-" * 52) -ForegroundColor DarkGray }
function OK    { param($t) Write-Host "  [OK] $t" -ForegroundColor Green }
function WARN  { param($t) Write-Host "  [REVISAR] $t" -ForegroundColor Yellow; $script:alertas++ }
function BAD   { param($t) Write-Host "  [NO CUMPLE] $t" -ForegroundColor Red; $script:bloqueos++ }
function INFO  { param($t) Write-Host "  $t" -ForegroundColor Gray }

Write-Host ""
Write-Host "  VERIFICADOR DE EQUIPO - TALLER 15 DE AGOSTO" -ForegroundColor Cyan
Write-Host "  Wellness Total" -ForegroundColor DarkGray
Linea

# --- 1. Sistema operativo ---
Write-Host "`n1) Sistema operativo" -ForegroundColor White
$os = Get-CimInstance Win32_OperatingSystem
$caption = $os.Caption
$build = [int]$os.BuildNumber
INFO $caption
if ($build -ge 22000)      { OK "Windows 11 (build $build)" }
elseif ($build -ge 17763)  { OK "Windows 10 compatible (build $build)" }
else                       { BAD "Se necesita Windows 10 1809 o superior (tienes build $build)" }

# --- 2. Procesador ---
Write-Host "`n2) Procesador" -ForegroundColor White
$cpu = (Get-CimInstance Win32_Processor | Select-Object -First 1).Name
if (-not $cpu) { $cpu = "desconocido" }
INFO $cpu.Trim()
$gen = $null
if ($cpu -match 'i[3579][- ](\d{4,5})') {
    $num = $matches[1]
    if ($num.Length -eq 5) { $gen = [int]$num.Substring(0,2) } else { $gen = [int]$num.Substring(0,1) }
}
if ($cpu -match 'Core\(TM\) Ultra|Core Ultra') {
    OK "Intel Core Ultra - supera el requisito"
} elseif ($gen -ne $null) {
    if ($gen -ge 6) { OK "Intel Core de ${gen}a generacion (se pide 6a o superior)" }
    else            { BAD "Intel Core de ${gen}a generacion - se pide 6a generacion o superior" }
} elseif ($cpu -match 'Ryzen') {
    OK "AMD Ryzen - cumple el requisito"
} elseif ($cpu -match 'Celeron|Pentium|Atom') {
    BAD "Procesador de gama baja - puede no rendir en el taller"
} else {
    WARN "No pudimos clasificar este procesador - mandanos la captura y lo revisamos"
}

# --- 3. Memoria RAM ---
Write-Host "`n3) Memoria RAM" -ForegroundColor White
$totalMB = [math]::Round($os.TotalVisibleMemorySize / 1KB)
$libreMB = [math]::Round($os.FreePhysicalMemory / 1KB)
$usoMem  = [math]::Round((1 - ($libreMB / $totalMB)) * 100)
$totalGB = [math]::Round($totalMB / 1024, 1)
INFO "$totalGB GB instalados - en uso ahora: $usoMem %"
if ($totalGB -ge 8)      { OK "Memoria suficiente" }
elseif ($totalGB -ge 4)  { WARN "$totalGB GB funciona pero va lento - recomendado 8 GB" }
else                     { BAD "Se necesitan al menos 4 GB" }
if ($usoMem -gt 50) { WARN "La memoria esta al $usoMem %. Cierra programas y vuelve a correr esto (se pide menos de 50 %)" }
else                { OK "Uso de memoria en $usoMem % (por debajo del 50 %)" }

# --- 4. Carga del procesador ---
Write-Host "`n4) Carga actual del procesador" -ForegroundColor White
$carga = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
if ($carga -eq $null) { $carga = 0 }
$carga = [math]::Round($carga)
INFO "Uso de CPU ahora: $carga %"
if ($carga -gt 50) { WARN "El procesador esta al $carga %. Cierra programas pesados (se pide menos de 50 %)" }
else               { OK "Carga del procesador en $carga % (por debajo del 50 %)" }

# --- 5. Espacio en disco ---
Write-Host "`n5) Espacio libre en disco" -ForegroundColor White
$libreGB = [math]::Round((Get-PSDrive C).Free / 1GB, 1)
INFO "$libreGB GB libres en C:"
if ($libreGB -ge 2) { OK "Espacio suficiente" }
else                { BAD "Se necesitan al menos 2 GB libres" }

# --- 6. Claude Code ---
Write-Host "`n6) Claude Code" -ForegroundColor White
$claude = Get-Command claude -ErrorAction SilentlyContinue
if ($claude) {
    $v = (claude --version 2>$null)
    OK "Instalado $v"
} else {
    INFO "Todavia no esta instalado (es el paso 2 de la guia)"
}

# --- Resultado ---
Linea
Write-Host ""
if ($bloqueos -gt 0) {
    Write-Host "  RESULTADO: hay $bloqueos punto(s) que NO cumplen" -ForegroundColor Red
    Write-Host "  Mandanos la captura por WhatsApp: la revision es GRATIS" -ForegroundColor White
    Write-Host "  y te decimos la opcion mas economica para dejarlo listo." -ForegroundColor White
} elseif ($alertas -gt 0) {
    Write-Host "  RESULTADO: equipo compatible con $alertas aviso(s)" -ForegroundColor Yellow
    Write-Host "  Mandanos la captura por WhatsApp y lo revisamos contigo." -ForegroundColor White
} else {
    Write-Host "  SEMAFORO VERDE - TU EQUIPO ESTA LISTO" -ForegroundColor Green
    Write-Host "  Mandanos la captura por WhatsApp para confirmarte." -ForegroundColor White
}
Write-Host ""
Write-Host "  WhatsApp: +52 1 55 4840 7552" -ForegroundColor Cyan
Write-Host "  Taller: sabado 15 de agosto, 9:00 h - Metepec" -ForegroundColor DarkGray
Write-Host ""
