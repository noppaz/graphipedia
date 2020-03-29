FROM maven:3.6.3-jdk-11-slim

ADD . .

RUN apt-get update
RUN apt-get install -y bzip2
RUN mvn clean package

CMD ["/import.sh", "input-file.xml.bz2", "/output-data"]