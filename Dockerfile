FROM python:3.8
WORKDIR /django
ENV PYTHONUNBUFFERED=1

RUN pip install --upgrade pip

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt