#!/bin/bash
# Verificador de equipo - Taller "Construye tu Operador de IA"
# Wellness Total - sabado 15 de agosto, Metepec
# Uso:  bash -c "$(curl -fsSL https://taller.wellnesstotal.tech/verifica.sh)"
#
# NOTA 1: sin acentos a proposito (encoding seguro en cualquier terminal)
# NOTA 2: solo comandos base de macOS (sw_vers, sysctl, vm_stat, df).
#         NO usar 'top' ni 'memory_pressure': el primero pelea con stdin
#         cuando el script llega por pipe y el segundo crashea en algunas Macs.
# NOTA 3: toda salida usa printf '%s\n' "..." para que un texto que empiece
#         con "-" o "%" nunca se interprete como opcion o formato.
# NOTA 4: cada comando lleva 2>/dev/null y </dev/null: ningun fallo
#         individual debe tumbar el verificador.

alertas=0
bloqueos=0

V=""; A=""; R=""; C=""; G=""; N=""
if [ -t 1 ]; then
  V=$'\033[0;32m'; A=$'\033[0;33m'; R=$'\033[0;31m'
  C=$'\033[0;36m'; G=$'\033[0;90m'; N=$'\033[0m'
fi

say()  { printf '%s\n' "$1"; }
ok()   { printf '%s\n' "  ${V}[OK]${N} $1"; }
warn() { printf '%s\n' "  ${A}[REVISAR]${N} $1"; alertas=$((alertas+1)); }
bad()  { printf '%s\n' "  ${R}[NO CUMPLE]${N} $1"; bloqueos=$((bloqueos+1)); }
info() { printf '%s\n' "  ${G}$1${N}"; }
linea(){ printf '%s\n' "${G}----------------------------------------------------${N}"; }

say ""
say "  ${C}VERIFICADOR DE EQUIPO - TALLER 15 DE AGOSTO${N}"
say "  ${G}Wellness Total${N}"
linea

# --- 1. Sistema operativo ---
say ""
say "1) Sistema operativo"
VER=$(sw_vers -productVersion 2>/dev/null </dev/null)
if [ -n "$VER" ]; then
  MAJOR=$(printf '%s' "$VER" | cut -d. -f1 2>/dev/null)
  info "macOS $VER"
  if [ -n "$MAJOR" ] && [ "$MAJOR" -ge 13 ] 2>/dev/null; then
    ok "Compatible (se pide macOS 13 Ventura o superior)"
  else
    bad "Se necesita macOS 13 (Ventura) o superior - tienes $VER"
  fi
else
  warn "No pudimos leer la version de macOS"
fi

# --- 2. Procesador ---
say ""
say "2) Procesador"
CPU=$(sysctl -n machdep.cpu.brand_string 2>/dev/null </dev/null)
if [ -z "$CPU" ]; then
  CPU=$(sysctl -n hw.model 2>/dev/null </dev/null)
fi
[ -z "$CPU" ] && CPU="desconocido"
info "$CPU"
if printf '%s' "$CPU" | grep -qE 'Apple M[0-9]' 2>/dev/null; then
  ok "Apple Silicon - supera el requisito"
elif printf '%s' "$CPU" | grep -qE 'i[3579][- ][0-9]{4,5}' 2>/dev/null; then
  NUM=$(printf '%s' "$CPU" | grep -oE 'i[3579][- ][0-9]{4,5}' 2>/dev/null | grep -oE '[0-9]{4,5}$' 2>/dev/null | head -1)
  if [ ${#NUM} -eq 5 ]; then
    GEN=$(printf '%s' "$NUM" | cut -c1-2 2>/dev/null)
  else
    GEN=$(printf '%s' "$NUM" | cut -c1 2>/dev/null)
  fi
  GEN=$((10#$GEN))
  if [ -n "$GEN" ] && [ "$GEN" -ge 6 ] 2>/dev/null; then
    ok "Intel Core de ${GEN}a generacion (se pide 6a o superior)"
  else
    bad "Intel Core de ${GEN}a generacion - se pide 6a generacion o superior"
  fi
elif printf '%s' "$CPU" | grep -qE 'Mac1[4-9]|Mac[2-9][0-9]' 2>/dev/null; then
  ok "Mac reciente - supera el requisito"
else
  warn "No pudimos clasificar este procesador - mandanos la captura y lo revisamos"
fi

# --- 3. Memoria RAM ---
say ""
say "3) Memoria RAM"
BYTES=$(sysctl -n hw.memsize 2>/dev/null </dev/null)
if [ -n "$BYTES" ]; then
  GB=$(awk -v b="$BYTES" 'BEGIN{printf "%.1f", b/1073741824}' 2>/dev/null </dev/null)
  GB_INT=$(awk -v b="$BYTES" 'BEGIN{printf "%d", b/1073741824}' 2>/dev/null </dev/null)
  info "$GB GB instalados"
  if [ "$GB_INT" -ge 8 ] 2>/dev/null; then
    ok "Memoria suficiente"
  elif [ "$GB_INT" -ge 4 ] 2>/dev/null; then
    warn "$GB GB funciona pero va lento - recomendado 8 GB"
  else
    bad "Se necesitan al menos 4 GB"
  fi

  VMS=$(vm_stat 2>/dev/null </dev/null)
  if [ -n "$VMS" ]; then
    PS=$(printf '%s' "$VMS" | head -1 | grep -oE '[0-9]+' 2>/dev/null | head -1)
    [ -z "$PS" ] && PS=4096
    LIBRES=$(printf '%s' "$VMS" | awk '/Pages free/ {gsub(/\./,"",$3); f=$3} /Pages inactive/ {gsub(/\./,"",$3); i=$3} /Pages speculative/ {gsub(/\./,"",$3); s=$3} END {print f+i+s}' 2>/dev/null </dev/null)
    if [ -n "$LIBRES" ] && [ "$LIBRES" -gt 0 ] 2>/dev/null; then
      USOMEM=$(awk -v l="$LIBRES" -v p="$PS" -v t="$BYTES" 'BEGIN{v=100-((l*p)/t*100); if(v<0)v=0; printf "%d", v}' 2>/dev/null </dev/null)
      info "Memoria en uso ahora: ${USOMEM} %"
      if [ "$USOMEM" -gt 50 ] 2>/dev/null; then
        warn "La memoria esta al ${USOMEM} %. Cierra programas y vuelve a correr esto (se pide menos de 50 %)"
      else
        ok "Uso de memoria en ${USOMEM} % (por debajo del 50 %)"
      fi
    fi
  fi
else
  warn "No pudimos leer la memoria instalada"
fi

# --- 4. Carga del procesador ---
say ""
say "4) Carga actual del procesador"
LOAD=$(sysctl -n vm.loadavg 2>/dev/null </dev/null | awk '{print $2}' 2>/dev/null </dev/null)
NCPU=$(sysctl -n hw.ncpu 2>/dev/null </dev/null)
if [ -n "$LOAD" ] && [ -n "$NCPU" ]; then
  USOCPU=$(awk -v l="$LOAD" -v n="$NCPU" 'BEGIN{v=l/n*100; if(v>100)v=100; printf "%d", v}' 2>/dev/null </dev/null)
  info "Uso de CPU ahora: ${USOCPU} % (promedio del ultimo minuto)"
  if [ "$USOCPU" -gt 50 ] 2>/dev/null; then
    warn "El procesador esta al ${USOCPU} %. Cierra programas pesados (se pide menos de 50 %)"
  else
    ok "Carga del procesador en ${USOCPU} % (por debajo del 50 %)"
  fi
else
  info "No pudimos medir la carga del procesador (no es bloqueante)"
fi

# --- 5. Espacio en disco ---
say ""
say "5) Espacio libre en disco"
LIBRE=$(df -g / 2>/dev/null </dev/null | awk 'NR==2 {print $4}' 2>/dev/null </dev/null)
if [ -n "$LIBRE" ]; then
  info "$LIBRE GB libres"
  if [ "$LIBRE" -ge 2 ] 2>/dev/null; then
    ok "Espacio suficiente"
  else
    bad "Se necesitan al menos 2 GB libres"
  fi
else
  warn "No pudimos leer el espacio en disco"
fi

# --- 6. Claude Code ---
say ""
say "6) Claude Code"
if command -v claude >/dev/null 2>&1; then
  CV=$(claude --version 2>/dev/null </dev/null)
  ok "Instalado $CV"
else
  info "Todavia no esta instalado (es el paso 2 de la guia)"
fi

# --- Resultado ---
say ""
linea
say ""
if [ "$bloqueos" -gt 0 ]; then
  say "  ${R}RESULTADO: hay $bloqueos punto(s) que NO cumplen${N}"
  say "  Mandanos la captura por WhatsApp: la revision es GRATIS"
  say "  y te decimos la opcion mas economica para dejarlo listo."
elif [ "$alertas" -gt 0 ]; then
  say "  ${A}RESULTADO: equipo compatible con $alertas aviso(s)${N}"
  say "  Mandanos la captura por WhatsApp y lo revisamos contigo."
else
  say "  ${V}SEMAFORO VERDE - TU EQUIPO ESTA LISTO${N}"
  say "  Mandanos la captura por WhatsApp para confirmarte."
fi
say ""
say "  ${C}WhatsApp: +52 1 55 4840 7552${N}"
say "  ${G}Taller: sabado 15 de agosto, 9:00 h - Metepec${N}"
say ""
exit 0
