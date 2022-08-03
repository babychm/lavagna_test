# Containerized application Lavagna via docker-compose
[source](https://github.com/digitalfondue/lavagna) of the original application


## Dockerization of the app

First of all,  there must be `Dockerfile` for dockerize the app:

```
FROM maven:3.8.6-jdk-8 as mavenbase
WORKDIR /usr/src/app
ADD . /usr/src/app
RUN mvn verify

FROM mavenbase
RUN chmod +x ./entrypoint.sh
ENTRYPOINT [ "./entrypoint.sh" ]
```

File entrypoint.sh describes all folowing steps after the start of the container, making it in separate file allows us to prevent redundancy of `Dockerfile`. So, the content of `entrypoint.sh`:

```
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
```


## Database connection and application orchestration

As a database for application I've choose MariaDB, which will run as docker container too.
To orchestrate application with DB, make the `docker-compose.yml` file:

```
version: "3"
services:
    api:
        build: .
        container_name: api
        ports:
            - "8080:8080"
        environment:
          DB_HOST: "db"
          DB_DIALECT: "MYSQL"
          DB_URL: "jdbc:mysql://db:3306/lavagna"
          DB_USER: ${MYSQL_UN_PW}
          DB_PASS: ${MYSQL_UN_PW}
          SPRING_PROFILE: "dev"
    db:
        container_name: db
        image: mariadb:10.8
        volumes:
          - ./lavagna_utf8.sql:/docker-entrypoint-initdb.d/lavagna_utf8.sql
          - DATA:/var/lib/mysql
        environment:
            MYSQL_ALLOW_EMPTY_PASSWORD: "yes"
            MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
#            MYSQL_USER: ${MYSQL_UN_PW}
            MYSQL_PASSWORD: ${MYSQL_UN_PW}
            MYSQL_DATABASE: "lavagna"
volumes:
    DATA:

```

Variables for `docker-compose.yml` determined in `.env` file and those file was added to `.gitignore` for security reasons. Example of `env`:

```
MYSQL_ROOT_PASSWORD=XXXXXXX
MYSQL_UN_PW=XXXXXXX

```


## Run the app
In order to run the application, you need first install [Docker](https://docs.docker.com/engine/install/) and [docker-compose](https://docs.docker.com/compose/install/), after that run
```
docker-compose up
```

And finally check the connection to [localhost:8080](http://localhost:8080)
