#!/bin/bash
# ============================================================
# auditoria_sistema.sh
# Laboratorio: Automatizacion de Auditoria y Control de Procesos
# ============================================================
# INTEGRANTE 1 → Seccion A y B
# INTEGRANTE 2 → Seccion C y D  (se agrega esta noche)
# INTEGRANTE 3 → Seccion E      (se agrega esta noche)
# ============================================================

# --- SECCION A: GESTION DE ARCHIVOS Y ENTORNO (FHS) ---
DIR_LOGS="$HOME/Logs_Auditoria"

if [ ! -d "$DIR_LOGS" ]; then
    mkdir -p "$DIR_LOGS"
    echo "[INFO] Directorio creado: $DIR_LOGS"
else
    echo "[INFO] Directorio ya existe: $DIR_LOGS"
fi

FECHA=$(date +"%d_%m_%Y")
REPORTE="$DIR_LOGS/reporte_$FECHA.log"
exec > >(tee -a "$REPORTE") 2>&1

echo "============================================================"
echo "  REPORTE DE AUDITORIA DEL SISTEMA"
echo "  Fecha: $(date '+%d/%m/%Y %H:%M:%S')"
echo "  Usuario: $(whoami) | Host: $(hostname)"
echo "============================================================"

# --- SECCION B: MONITORIZACION DE RENDIMIENTO (METODO USE) ---
echo ""
echo "--- [B] MONITORIZACION DE RENDIMIENTO ---"

LOAD=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
echo "[LOAD AVERAGE] 1, 5 y 15 minutos: $LOAD"

echo ""
echo "[TOP 3 PROCESOS - CPU]"
ps aux --sort=-%cpu | awk 'NR==2,NR==4 {printf "PID:%-8s CPU:%-6s CMD:%s\n", $2, $3, $11}'

TOP_PID=$(ps aux --sort=-%cpu | awk 'NR==2 {print $2}')
TOP_CMD=$(ps aux --sort=-%cpu | awk 'NR==2 {print $11}')

echo ""
echo "[INFO] PID mas pesado: $TOP_PID ($TOP_CMD)"

# --- SECCION C y D: Integrante 2 agrega aqui esta noche ---
# --- SECCION C: DIAGNOSTICO DE PROCESOS ZOMBI ---
echo ""
echo "--- [C] DIAGNOSTICO DE PROCESOS ZOMBI ---"
ZOMBIES=$(ps aux | awk '$8 == "Z" {print $2}')
if [ -z "$ZOMBIES" ]; then
    echo "[OK] Sin procesos zombi detectados."
else
    for Z in $ZOMBIES; do
        PPID=$(ps -o ppid= -p "$Z" | tr -d ' ')
        PNAME=$(ps -o comm= -p "$PPID")
        echo "Zombi PID:$Z  PPID:$PPID  Padre:$PNAME"
    done
fi

# --- SECCION D: RENICE +15 ---
echo ""
echo "--- [D] OPTIMIZACION DE PRIORIDAD ---"
NICE_ANTES=$(ps -o ni= -p "$TOP_PID" | tr -d ' ')
echo "[INFO] Niceness antes: $NICE_ANTES"
renice +15 -p "$TOP_PID" 2>/dev/null
NICE_DESPUES=$(ps -o ni= -p "$TOP_PID" | tr -d ' ')
echo "[INFO] Niceness despues: $NICE_DESPUES"

# --- SECCION E: Integrante 3 agrega aqui esta noche ---

echo ""
echo "============================================================"
echo "  Reporte guardado en: $REPORTE"
echo "============================================================"
