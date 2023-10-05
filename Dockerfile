FROM python:3.8-alpine
WORKDIR /django
ENV PYTHONUNBUFFERED=1
RUN apk update && apk add postgresql-dev gcc python3-dev musl-dev make cmake g++ zlib-dev dpkg git curl
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt