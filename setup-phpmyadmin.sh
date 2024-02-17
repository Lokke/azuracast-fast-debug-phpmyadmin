#!/bin/bash

# Set the path to the azuracast.env file
AZURACAST_ENV_PATH="/var/azuracast/azuracast.env"

# Check if the azuracast.env file exists
if [ ! -f "$AZURACAST_ENV_PATH" ]; then
    echo "The file azuracast.env was not found at $AZURACAST_ENV_PATH"
    exit 1
fi

# Read the environment variables from the azuracast.env file
MYSQL_USER=$(grep ^MYSQL_USER= "$AZURACAST_ENV_PATH" | cut -d= -f2)
MYSQL_PASSWORD=$(grep ^MYSQL_PASSWORD= "$AZURACAST_ENV_PATH" | cut -d= -f2)

# Prompt for the port to be published
read -p "Enter the port to publish for phpMyAdmin (default: 8080): " PORT
PORT=${PORT:-8080}

# Create the Docker Compose file
cat <<EOF > docker-compose.yml
version: '3.1'

services:
  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    restart: always
    ports:
      - "$PORT:80"
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

echo "The Docker Compose file was created successfully."

# Prompt to start the containers
read -p "Do you want to start the containers? ([yes]/no): " start_response
start_response=${start_response:-yes}

if [ "$start_response" = "yes" ] || [ "$start_response" = "y" ]; then
    # Prompt whether containers should run as daemons
    read -p "Should the containers run as daemons? ([Yes]/no): " daemon_response
    daemon_response=${daemon_response:-Yes}
    if [ "$daemon_response" = "Yes" ] || [ "$daemon_response" = "yes" ] || [ "$daemon_response" = "Y" ]; then
        docker-compose up -d
    else
        docker-compose up
    fi
fi
