
```
+---------------+   +-------------------------+   +--------------------------+   +-------------+
|               |   |                         |   |                          |   |             |
|               |   |                         |   |                          |   |             |
|  Postgres DB  +---+  Backend microservice   +---+   Frontend microservice  +-->--  Web       |
|               +--->      Python Flask       +--->           React          |   |   Browser   |
|               |   |                         |   |                          |   |             |
+---------------+   +-------------------------+   +--------------------------+   +-------------+
```
# Run simple python/react application locally

## Steps-to-follow
* Install Docker (Needed for PostgreSQL)
* Run ligtweight PostgreSQL database as docker container
* Install python 3
* Run Backend microservice localy
* Install npm
* Run Frontend microservice localy 

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

Install Python 3

Switch to project dir
```
cd <LOCAL_PATH>/open-alt209/easy-python-app/backend/
```
Export environmental var
```
export PSQL_DB_USER='micro'
export PSQL_DB_NAME='microservice'
export PSQL_DB_ADDRESS='127.0.0.1'
export PSQL_DB_PASS='password'
export PSQL_DB_PORT='5432'
```
Create python virtualenv
```
python3 -m venv venv_micro
```

Activate virtualenv 
```
source venv_micro/bin/activate
```

Install requirements from requirements.txt
```
pip install -r requirements.txt
```

Start Flask 
```
export FLASK_APP=app
flask run --host=0.0.0.0 --port=8000
```

## Run Frontend microservice

Install npm

Switch to project dir
```
cd <LOCAL_PATH>/open-alt209/easy-python-app/frontend/
```
Update get requests in `App.js` file in `frontend/src/` dir to reflect `backend-microservice` running on localhost:8000

Build and start React Frontend microservice
```
npm install
npm start
```



