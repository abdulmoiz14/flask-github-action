
FROM python:3.8-slim-buster
LABEL maintainer = "abdulmoiz1443@gmail.com"
WORKDIR /

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY templates templates

COPY . /

EXPOSE 8080

CMD ["python", "app.py"]
