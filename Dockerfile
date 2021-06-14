FROM python:3.8-slim-buster

WORKDIR /usr/src/app

COPY requirements.txt requirements.txt

RUN python3 -m pip install -r requirements.txt

COPY ./app .

ENTRYPOINT python app.py