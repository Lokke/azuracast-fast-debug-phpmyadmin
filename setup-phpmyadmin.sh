#!/bin/bash

# Setze den Pfad zur azuracast.env-Datei
AZURACAST_ENV_PATH="/var/azuracast/azuracast.env"

# Überprüfe, ob die azuracast.env-Datei existiert
if [ ! -f "$AZURACAST_ENV_PATH" ]; then
    echo "Die Datei azuracast.env wurde nicht gefunden unter $AZURACAST_ENV_PATH"
    exit 1
fi

# Lies die Umgebungsvariablen aus der azuracast.env-Datei
MYSQL_USER=$(grep ^MYSQL_USER= "$AZURACAST_ENV_PATH" | cut -d= -f2)
MYSQL_PASSWORD=$(grep ^MYSQL_PASSWORD= "$AZURACAST_ENV_PATH" | cut -d= -f2)

# Erstelle das Docker Compose-File
cat <<EOF > docker-compose.yml
version: '3.1'

services:
  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    restart: always
    ports:
      - "8855:80"
    environment:
      - PMA_HOST=azuracast
      - PMA_USER=${MYSQL_USER}
      - PMA_PASSWORD=${MYSQL_PASSWORD}
    networks:
      - azuracast_default

networks:
  azuracast_default:
    external: true
EOF

echo "Das Docker Compose-File wurde erfolgreich erstellt."

# Abfrage, ob das erstellte Skript gestartet werden soll
read -p "Möchten Sie das erstellte Skript starten? (ja/nein): " start_response

if [ "$start_response" == "ja" ]; then
    # Abfrage, ob es als Daemon laufen soll
    read -p "Soll das Skript als Daemon laufen? (ja/nein): " daemon_response
    if [ "$daemon_response" == "ja" ]; then
        docker-compose up -d
    else
        docker-compose up
    fi
fi
