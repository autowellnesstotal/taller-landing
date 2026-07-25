#!/bin/bash
# Verificador de equipo — Taller "Construye tu Operador de IA"
# Wellness Total — sábado 15 de agosto, Metepec
echo "============================================"
echo " VERIFICADOR DE EQUIPO — TALLER 15 DE AGOSTO"
echo "============================================"
echo ""
echo "[1/5] Versión de macOS (se necesita macOS 12 o superior):"
sw_vers 2>/dev/null | sed 's/^/   /'
echo ""
echo "[2/5] Memoria RAM (recomendado 8 GB, mínimo 4 GB):"
sysctl -n hw.memsize 2>/dev/null | awk '{printf "   %.1f GB instalados\n", $1/1073741824}'
echo ""
echo "[3/5] Espacio libre en disco (se necesitan 2 GB o más):"
df -h / | awk 'NR==2 {print "   " $4 " libres"}'
echo ""
echo "[4/5] Node.js (se instala en el paso 2 de la guía):"
if command -v node >/dev/null 2>&1; then
  echo "   OK — Node $(node --version) instalado"
else
  echo "   PENDIENTE — aún no está instalado. Sigue el paso 2 de la guía."
fi
echo ""
echo "[5/5] Claude Code (se instala en el paso 2 de la guía):"
if command -v claude >/dev/null 2>&1; then
  echo "   OK — Claude Code $(claude --version 2>/dev/null) instalado"
else
  echo "   PENDIENTE — aún no está instalado. Sigue el paso 2 de la guía."
fi
echo ""
echo "============================================"
echo " Tómale una captura a esta ventana y mándala"
echo " por WhatsApp: +52 1 55 4840 7552"
echo " — Si todo dice OK: ese es tu semáforo verde"
echo " — Si algo dice PENDIENTE: te ayudamos sin"
echo "   costo a dejarlo listo"
echo "============================================"
echo ""
read -p "Presiona Enter para cerrar..."
