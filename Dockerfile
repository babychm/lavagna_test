FROM maven:3.8.6-jdk-8 as mavenbase
WORKDIR /usr/src/app
ADD . /usr/src/app
RUN mvn verify

FROM mavenbase
RUN chmod +x ./entrypoint.sh
ENTRYPOINT [ "./entrypoint.sh" ]
