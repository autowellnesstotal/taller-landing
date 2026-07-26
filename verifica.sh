#!/bin/bash
# Verificador de equipo - Taller "Construye tu Operador de IA"
# Wellness Total - sabado 15 de agosto, Metepec
# Uso:  curl -fsSL https://taller.wellnesstotal.tech/verifica.sh | bash
# NOTA: sin acentos a proposito (encoding seguro en cualquier terminal)

V="\033[0;32m"; A="\033[0;33m"; R="\033[0;31m"; C="\033[0;36m"; G="\033[0;90m"; N="\033[0m"
alertas=0
bloqueos=0

ok()   { echo -e "  ${V}[OK]${N} $1"; }
warn() { echo -e "  ${A}[REVISAR]${N} $1"; alertas=$((alertas+1)); }
bad()  { echo -e "  ${R}[NO CUMPLE]${N} $1"; bloqueos=$((bloqueos+1)); }
info() { echo -e "  ${G}$1${N}"; }
linea(){ echo -e "${G}----------------------------------------------------${N}"; }

echo ""
echo -e "  ${C}VERIFICADOR DE EQUIPO - TALLER 15 DE AGOSTO${N}"
echo -e "  ${G}Wellness Total${N}"
linea

# --- 1. Sistema operativo ---
echo ""
echo "1) Sistema operativo"
VER=$(sw_vers -productVersion 2>/dev/null)
MAJOR=$(echo "$VER" | cut -d. -f1)
info "macOS $VER"
if [ -z "$MAJOR" ]; then
  warn "No pudimos leer la version de macOS"
elif [ "$MAJOR" -ge 13 ]; then
  ok "Compatible (se pide macOS 13 Ventura o superior)"
else
  bad "Se necesita macOS 13 (Ventura) o superior - tienes $VER"
fi

# --- 2. Procesador ---
echo ""
echo "2) Procesador"
CPU=$(sysctl -n machdep.cpu.brand_string 2>/dev/null)
[ -z "$CPU" ] && CPU="desconocido"
info "$CPU"
if echo "$CPU" | grep -qE 'Apple M[0-9]'; then
  ok "Apple Silicon - supera el requisito"
elif echo "$CPU" | grep -qE 'i[3579][- ][0-9]{4,5}'; then
  NUM=$(echo "$CPU" | grep -oE 'i[3579][- ][0-9]{4,5}' | grep -oE '[0-9]{4,5}$')
  if [ ${#NUM} -eq 5 ]; then GEN=${NUM:0:2}; else GEN=${NUM:0:1}; fi
  GEN=$((10#$GEN))
  if [ "$GEN" -ge 6 ]; then
    ok "Intel Core de ${GEN}a generacion (se pide 6a o superior)"
  else
    bad "Intel Core de ${GEN}a generacion - se pide 6a generacion o superior"
  fi
else
  warn "No pudimos clasificar este procesador - mandanos la captura y lo revisamos"
fi

# --- 3. Memoria RAM ---
echo ""
echo "3) Memoria RAM"
BYTES=$(sysctl -n hw.memsize 2>/dev/null)
if [ -n "$BYTES" ]; then
  GB=$(echo "$BYTES" | awk '{printf "%.1f", $1/1073741824}')
  GB_INT=$(echo "$BYTES" | awk '{printf "%d", $1/1073741824}')
  info "$GB GB instalados"
  if [ "$GB_INT" -ge 8 ]; then
    ok "Memoria suficiente"
  elif [ "$GB_INT" -ge 4 ]; then
    warn "$GB GB funciona pero va lento - recomendado 8 GB"
  else
    bad "Se necesitan al menos 4 GB"
  fi
else
  warn "No pudimos leer la memoria instalada"
fi

FREEPCT=$(memory_pressure 2>/dev/null | grep -i "free percentage" | grep -oE '[0-9]+' | tail -1)
if [ -n "$FREEPCT" ]; then
  USOMEM=$((100 - FREEPCT))
  info "Memoria en uso ahora: ${USOMEM} %"
  if [ "$USOMEM" -gt 50 ]; then
    warn "La memoria esta al ${USOMEM} %. Cierra programas y vuelve a correr esto (se pide menos de 50 %)"
  else
    ok "Uso de memoria en ${USOMEM} % (por debajo del 50 %)"
  fi
fi

# --- 4. Carga del procesador ---
echo ""
echo "4) Carga actual del procesador"
IDLE=$(top -l 1 -n 0 2>/dev/null | grep "CPU usage" | grep -oE '[0-9]+\.[0-9]+% idle' | grep -oE '^[0-9]+')
if [ -n "$IDLE" ]; then
  USOCPU=$((100 - IDLE))
  info "Uso de CPU ahora: ${USOCPU} %"
  if [ "$USOCPU" -gt 50 ]; then
    warn "El procesador esta al ${USOCPU} %. Cierra programas pesados (se pide menos de 50 %)"
  else
    ok "Carga del procesador en ${USOCPU} % (por debajo del 50 %)"
  fi
else
  info "No pudimos medir la carga del procesador (no es bloqueante)"
fi

# --- 5. Espacio en disco ---
echo ""
echo "5) Espacio libre en disco"
LIBRE=$(df -g / 2>/dev/null | awk 'NR==2 {print $4}')
if [ -n "$LIBRE" ]; then
  info "$LIBRE GB libres"
  if [ "$LIBRE" -ge 2 ]; then ok "Espacio suficiente"; else bad "Se necesitan al menos 2 GB libres"; fi
else
  warn "No pudimos leer el espacio en disco"
fi

# --- 6. Claude Code ---
echo ""
echo "6) Claude Code"
if command -v claude >/dev/null 2>&1; then
  ok "Instalado $(claude --version 2>/dev/null)"
else
  info "Todavia no esta instalado (es el paso 2 de la guia)"
fi

# --- Resultado ---
echo ""
linea
echo ""
if [ "$bloqueos" -gt 0 ]; then
  echo -e "  ${R}RESULTADO: hay $bloqueos punto(s) que NO cumplen${N}"
  echo "  Mandanos la captura por WhatsApp: la revision es GRATIS"
  echo "  y te decimos la opcion mas economica para dejarlo listo."
elif [ "$alertas" -gt 0 ]; then
  echo -e "  ${A}RESULTADO: equipo compatible con $alertas aviso(s)${N}"
  echo "  Mandanos la captura por WhatsApp y lo revisamos contigo."
else
  echo -e "  ${V}SEMAFORO VERDE - TU EQUIPO ESTA LISTO${N}"
  echo "  Mandanos la captura por WhatsApp para confirmarte."
fi
echo ""
echo -e "  ${C}WhatsApp: +52 1 55 4840 7552${N}"
echo -e "  ${G}Taller: sabado 15 de agosto, 9:00 h - Metepec${N}"
echo ""
