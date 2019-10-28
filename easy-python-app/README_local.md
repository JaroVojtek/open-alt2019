
# 1. Run simple Easy-web-form python application in Docker container

## Steps-to-follow
* Install Docker
* Run ligtweight PostgreSQL database as docker container
* Build own lightweight Docker image for application using Dockerfile
* Run simple python application BookStore as Docker container

## Docker installation
Switch to root
```
sudo -i 
```
Install Docker on Linux system
```
curl -fsSL get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```
Starting docker service
```
systemctl start docker
systemctl status docker
```

## Run PostgreSQL 

```
docker run --net=host --rm \
--name micro-postgres \
-e POSTGRES_USER=postgres \
-e POSTGRES_PASSWORD=admin-pass \
-d postgres:alpine
```
Check if PostgreSQL started and is listening on port 5432 on localhost
```
docker ps
netstat -tunlp | grep 5432
```
Connect to PostgreSQL from your laptop
```
psql --host=localhost --port=5432 -U postgres
```
Create database, user and grant privileges
```
CREATE DATABASE  microservice;
CREATE USER micro WITH ENCRYPTED PASSWORD 'password'; 
GRANT ALL PRIVILEGES ON DATABASE microservice TO micro;
ALTER DATABASE microservice OWNER TO micro;
```
Connect to databse and check request_ips table
```
psql --host=localhost --port=5432 -U micro -d microservice
select * from request_ips;
```

## Run Backend microservice

Clone project



