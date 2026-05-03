#!/bin/bash

DIR_LOGS="$HOME/Logs_Auditoria"

if [ ! -d "$DIR_LOGS" ]; then
    mkdir "$DIR_LOGS"
    echo "Directorio creado: $DIR_LOGS"
fi

FECHA=$(date +"%d_%m_%Y")
REPORTE="$DIR_LOGS/reporte_$FECHA.log"

{
echo "==== REPORTE DE AUDITORIA ===="
echo "Fecha: $(date)"
echo "Usuario: $(whoami)"
echo ""

echo "--- LOAD AVERAGE ---"
uptime

echo ""
echo "--- TOP 3 PROCESOS CPU ---"
ps aux --sort=-%cpu | head -4

TOP_PID=$(ps aux --sort=-%cpu | awk 'NR==2 {print $2}')
TOP_CMD=$(ps aux --sort=-%cpu | awk 'NR==2 {print $11}')
echo ""
echo "Proceso mas pesado: PID=$TOP_PID  CMD=$TOP_CMD"

echo ""
echo "--- ERRORES DE RED (RX/TX) ---"
ip -s link | awk '
    /^[0-9]+:/ {iface=$2}
    /RX:/ {getline; printf "%-12s RX errors=%s dropped=%s\n", iface, $3, $4}
    /TX:/ {getline; printf "%-12s TX errors=%s dropped=%s\n", iface, $3, $4}'

echo ""
echo "--- PROCESOS ZOMBI ---"
ZOMBIES=$(ps aux | awk '$8 ~ /Z/ {print $2}')
if [ -z "$ZOMBIES" ]; then
    echo "Sin zombis."
else
    for Z in $ZOMBIES; do
        PADRE=$(ps -o ppid= -p $Z)
        NOMBRE=$(ps -o comm= -p $PADRE)
        echo "Zombi PID=$Z  PPID=$PADRE  Padre=$NOMBRE"
    done
fi

echo ""
echo "--- OPTIMIZACION (RENICE) ---"
echo "Niceness antes: $(ps -o ni= -p $TOP_PID)"
renice +15 -p $TOP_PID
echo "Niceness despues: $(ps -o ni= -p $TOP_PID)"

} | tee "$REPORTE"

echo ""
echo "--- ENVIO DE SEÑAL ---"
echo "1) SIGTERM (15)"
echo "2) SIGKILL (9)"
echo "3) No enviar"
read -p "Opcion: " OPT

case $OPT in
    1) kill -15 $TOP_PID ; echo "SIGTERM enviado a $TOP_PID" ;;
    2) kill -9  $TOP_PID ; echo "SIGKILL enviado a $TOP_PID" ;;
    3) echo "Sin accion" ;;
    *) echo "Opcion invalida" ;;
esac

echo "Reporte guardado en: $REPORTE"
