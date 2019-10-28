# Run simple python/react application in docker containers

## Steps-to-follow
* Run ligtweight PostgreSQL database as docker container
* Build backend docker image from Dockerfile
* Run backend microservice in docker container 
* Build frontend docker image from Dockerfile
* Run frontend microservice in docker container


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

## Build backend docker image from Dockerfile

Switch to project dir
```
cd <LOCAL_PATH>/open-alt209/easy-python-app/backend/
```
Build backend docker image from Dockerfile
```
docker build -t backend-microservice:0.0.1 .
```
Check newly build backend microservice docker image
```
docker images
```
## Run backend microservice in docker container 
```
docker run \
-p 8000:8000 \
--rm \
--name backend-microservice \
-d \
-e PSQL_DB_USER='micro' \
-e PSQL_DB_NAME='microservice' \
-e PSQL_DB_ADDRESS='<MY_IP_ADDRESS>' \
-e PSQL_DB_PASS='password' \
-e PSQL_DB_PORT='5432' \
-d backend-microservice:0.0.1
```
Verify functionality of backend microservice running in docker container
```
docker ps
docker inspect <CONTAINER_ID> | grep -i ipaddress
netstat -tunlp | grep -i 8000
wget -O - http://<CONTAINER_IP>:8000/api/isalive
```

## Build frontend docker image from Dockerfile
Switch to project dir
```
cd <LOCAL_PATH>/open-alt209/easy-python-app/frontend/
```
Update get requests in `App.js` file in `frontend/src/` dir to reflect `backend-microservice` container ip

Build backend docker image from Dockerfile
```
docker build -t frontend-microservice:0.0.1 .
```
Check newly build backend microservice docker image
```
docker images
```

## Run frontend microservice in docker container 

```
docker run -p 5000:80 \
--rm --name frontend-microservice \
-d frontend-microservice:0.0.1
```