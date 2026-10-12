#!/bin/bash

# Script to download songs from Tidal using tidal-dl
# Input file: canciones.txt (must contain URLs, one per line)

ARCHIVO="canciones"
LOG_FILE="descarga_log.txt"

# Check that the file exists
if [ ! -f "$ARCHIVO" ]; then
	echo "Error: El archivo '$ARCHIVO' no existe."
	exit 1
fi

# Check that tidal-dl is installed
if ! command -v tidal-dl &>/dev/null; then
	echo "Error: tidal-dl no está instalado o no está en el PATH."
	exit 1
fi

# Count the total number of songs
TOTAL=$(wc -l <"$ARCHIVO")
CONTADOR=0

echo "======================================"
echo "Iniciando descarga de $TOTAL canciones"
echo "======================================"
echo ""

# Start log
echo "Inicio de descarga: $(date)" >"$LOG_FILE"

# Read the file line by line
while IFS= read -r url || [ -n "$url" ]; do
	# Skip empty lines or comments
	if [[ -z "$url" ]] || [[ "$url" =~ ^# ]]; then
		continue
	fi

	CONTADOR=$((CONTADOR + 1))
	echo "[$CONTADOR/$TOTAL] Descargando: $url"

	# Run tidal-dl
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

# Finish log
echo "Fin de descarga: $(date)" >>"$LOG_FILE"
