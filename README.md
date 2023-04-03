# github action for flask python and postgress
## Do these steps for Continuous integration 
**create .github/workflow/main.yml**<br />
**edit and add event in main.yml**<br />
```
name: CI/CD pipeline
on:
  push:
    branches:
      - 'main'
```
**edit in  dockerfile for flask python**
```
FROM python:3.8-slim-buster
LABEL maintainer = "abdulmoiz1443@gmail.com"
WORKDIR /

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY templates templates

COPY . /

EXPOSE 8080

CMD ["python", "app.py"]
```
**Add python web job in main.yml**
```
jobs:
  python_build:
    needs: postrges_build
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      - name: Set up Python
        uses: actions/setup-python@v3
        with:
          python-version: 3.x

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
      - name: build image
        run: docker build . --file dockerfile --tag web
```
**Add dockerfile for postgres and edit in it.**
```
FROM postgres:13-alpine
```
**Now add job for postgres.**
```
  postrges_build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      - uses: harmon758/postgresql-action@v1
        with:
          postgresql_version: 'alpine3.17'
        env:
          POSTGRES_PASSWORD: ${{ secrets.POSTGRES_PASSWORD }}
          POSTGRES_USER: ${{ secrets.POSTGRES_USER }}
          POSTGRES_DB: ${{ secrets.POSTGRES_DB }}
      - name: build image
        run: docker build . --file db/dockerfile --tag postgres_db
```
****
