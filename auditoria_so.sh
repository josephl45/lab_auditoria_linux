#!/bin/bash

# --- SECCION A ---

mkdir -p ~/Logs_Auditoria
REPORTE=~/Logs_Auditoria/reporte_$(date +'%d_%m_%Y').log

echo "Reporte: $(date)" > $REPORTE

# --- SECCION B ---

echo "Load Average:" >> $REPORTE
uptime >> $REPORTE

echo "Top 3 procesos CPU:" >> $REPORTE
ps aux --sort=-%cpu | head -4 >> $REPORTE

TOP_PID=$(ps aux --sort=-%cpu | awk 'NR==2 {print $2}')
echo "Proceso mas pesado PID: $TOP_PID" >> $REPORTE

cat $REPORTE
