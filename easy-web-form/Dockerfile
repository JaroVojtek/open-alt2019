FROM ubuntu:latest

RUN apt-get update
RUN apt-get -y install python3 python3-tk
RUN apt-get clean
COPY ./app/* /app/
WORKDIR /app
CMD python3 frontend.py


