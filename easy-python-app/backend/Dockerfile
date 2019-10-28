FROM python:3-alpine

RUN mkdir -p /data/microservice

# We copy just the requirements.txt first to leverage Docker cache
COPY ["requirements.txt","app.py", "/data/"]
COPY ["microservice/", "/data/microservice/"]

RUN apk update \
 && apk add --virtual build-deps gcc python3-dev musl-dev \
 && apk add postgresql-dev \
 && pip install --upgrade pip \
 && pip install -r /data/requirements.txt \
 && apk del build-deps


WORKDIR /data

ENTRYPOINT ["gunicorn"]

CMD ["--bind", "0.0.0.0:8000", "app:app"]