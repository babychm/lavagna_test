#!/bin/sh
apt-get update -y && apt-get dist-upgrade -y
apt-get install -y mariadb-client

sleep 2
while ! mysqladmin ping -h"$DB_HOST" --silent; do
    sleep 2
done

java -Xms64m -Xmx128m -Ddatasource.dialect="${DB_DIALECT}" \
-Ddatasource.url="${DB_URL}" \
-Ddatasource.username="${DB_USER}" \
-Ddatasource.password="${DB_PASS}" \
-Dspring.profiles.active="${SPRING_PROFILE}" \
-jar target/lavagna-jetty-console.war --headless
