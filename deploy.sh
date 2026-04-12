#!/bin/bash
set -e
export IMAGE_TAG=${1:-latest}

echo "=== Pulling image and starting services ==="
docker compose pull
docker compose up -d --remove-orphans

echo "=== Waiting for MySQL to be ready (30s) ==="
sleep 30

echo "=== Initializing user sa3000udp ==="
# Используем -T для неинтерактивного режима
docker compose exec -T app python3 -c '
import mysql.connector
try:
    db_config = {"host": "db", "user": "user", "password": "password", "database": "reminders"}
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()
    cursor.execute("CREATE TABLE IF NOT EXISTS users (id INT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(255) UNIQUE, password VARCHAR(255))")
    cursor.execute("INSERT IGNORE INTO users (username, password) VALUES (\"sa3000udp\", \"password\")")
    conn.commit()
    print("User sa3000udp ensured successfully")
except Exception as e:
    print(f"Error: {e}")
    exit(1)
'

echo "=== DEPLOY DONE ==="
