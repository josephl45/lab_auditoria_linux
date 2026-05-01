Jose Luis Curup Aquino, 2294-23-11148
Julio César Rodríguez Meza, 2294-23-5153
Javier Emanuel García Vásquez, 2294-23-18147

## Como ejecutar el script

### 1. Generar carga de trabajo (ejecutar antes del script)
```bash
cat /dev/urandom | gzip -9 > /dev/null &
sleep 3000 &
```

### 2. Dar permisos de ejecucion
```bash
chmod +x auditoria_sistema.sh
```

### 3. Ejecutar el script
```bash
bash auditoria_sistema.sh
```

### 4. Ver el reporte generado
```bash
cat ~/Logs_Auditoria/reporte_$(date +'%d_%m_%Y').log
