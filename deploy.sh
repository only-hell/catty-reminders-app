#!/bin/bash
export IMAGE_TAG=${1:-latest}
docker compose pull
docker compose up -d
# Даем базе проснуться и создаем таблицу пользователей (как мы делали раньше)
sleep 15
docker compose exec -T app python3 -c 'from app.utils.mysql_storage import MySQLStorage; db_config = {"host": "db", "user": "user", "password": "password", "database": "reminders"}; storage = MySQLStorage("system", db_config); storage.cursor.execute("INSERT IGNORE INTO users (username, password) VALUES (\"sa3000udp\", \"password\")"); storage.conn.commit()'
