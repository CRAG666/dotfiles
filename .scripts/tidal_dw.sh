#!/bin/bash

# Script para descargar canciones desde Tidal usando tidal-dl
# Archivo de entrada: canciones.txt (debe contener URLs, una por línea)

ARCHIVO="canciones"
LOG_FILE="descarga_log.txt"

# Verificar si el archivo existe
if [ ! -f "$ARCHIVO" ]; then
	echo "Error: El archivo '$ARCHIVO' no existe."
	exit 1
fi

# Verificar si tidal-dl está instalado
if ! command -v tidal-dl &>/dev/null; then
	echo "Error: tidal-dl no está instalado o no está en el PATH."
	exit 1
fi

# Contar el número total de canciones
TOTAL=$(wc -l <"$ARCHIVO")
CONTADOR=0

echo "======================================"
echo "Iniciando descarga de $TOTAL canciones"
echo "======================================"
echo ""

# Iniciar log
echo "Inicio de descarga: $(date)" >"$LOG_FILE"

# Leer el archivo línea por línea
while IFS= read -r url || [ -n "$url" ]; do
	# Saltar líneas vacías o comentarios
	if [[ -z "$url" ]] || [[ "$url" =~ ^# ]]; then
		continue
	fi

	CONTADOR=$((CONTADOR + 1))
	echo "[$CONTADOR/$TOTAL] Descargando: $url"

	# Ejecutar tidal-dl
	if tidal-dl -l "$url"; then
		echo "  ✓ Descarga exitosa" | tee -a "$LOG_FILE"
	else
		echo "  ✗ Error al descargar" | tee -a "$LOG_FILE"
	fi

	echo ""
done <"$ARCHIVO"

echo "======================================"
echo "Proceso completado: $CONTADOR/$TOTAL canciones procesadas"
echo "Revisa '$LOG_FILE' para más detalles"
echo "======================================"

# Finalizar log
echo "Fin de descarga: $(date)" >>"$LOG_FILE"
