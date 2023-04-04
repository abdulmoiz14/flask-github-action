# GitHub action for flask python and postgress
## Do these steps for Continuous integration 
### create .github/workflow/main.yml
**edit and add event in main.yml**
```
name: CI/CD pipeline
on:
  push:
    branches:
      - 'main'
```
### edit in  dockerfile for flask python.
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
### Add python web job in main.yml
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
      - name: run image
        run: docker run  --name web_container1 web sleep 100
```
### Add dockerfile for postgres and edit in it.
```
FROM postgres:13-alpine
EXPOSE 5432
```
### Now add postgres job in main.yml.
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
          POSTGRES_PASSWORD : ${{ secrets.POSTGRES_PASSWORD }}
          POSTGRES_USER : ${{ secrets.POSTGRES_USER }}
          POSTGRES_DB : ${{ secrets.POSTGRES_DB }}
      - name: build image
        run: docker build . --file db/dockerfile --tag postgres_db
      - name: run image
        run: docker run -d -p 5432:5432 --name postgres_container1 postgres_db
```
**Add POSTGRES_PASSWORD,POSTGRES_USER and POSTGRES_DB in secret variable of action in setting of the project repository.**
### Use super linter job in main.yml for unit testing.
```
lint_built:
    name: Lint Code Base 
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3
        with:
          fetch-depth: 0
      - name: Lint Code Base
        uses: github/super-linter@v4
        env:
          VALIDATE_ALL_CODEBASE: false
          DEFAULT_BRANCH: main
          GITHUB_TOKEN: ${{ secrets.TOKEN }}

```
**Add TOKEN in secret variable of action in setting of the project repository.**<br />
**Continuous Integration successfully integrated.**<br />
![Screenshot (92)](https://user-images.githubusercontent.com/65711565/229436962-2f8c9045-bc9a-4866-9a9d-6b69407dc336.png)
## Do these steps for Continuous deployment.
**Open setting -> action -> runner**<br />
**Click 'New self-hosted runner' and Copy these commands in AWS -> EC2 -> instance(runner)**<br />
![Screenshot (95)](https://user-images.githubusercontent.com/65711565/229584712-e446c583-a468-4c98-a23f-262112973df7.png)
### connect your runner and install docker in it.
**Use this command to ready runner for listening to jobs.**
```
./run.sh
```
**Now copy your runner labels in run-on step of main.yml**<br />
### This is the fully upgraded file of main.yml
```
name: CI/CD pipeline
on:
  push:
    branches:
      - 'main'
      
jobs:
  python_build:
    needs: lint_build
    runs-on: [self-hosted, Linux, X64, arm64]
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
      - name: run image
        run: docker run -d --name web_container1 web sleep 100
        
  postgres_build:
    runs-on: [self-hosted, Linux, X64, arm64]
    needs: lint_build
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      - uses: harmon758/postgresql-action@v1
        with:
          postgresql_version: 'alpine3.17'
        env:
          POSTGRES_PASSWORD : ${{ secrets.POSTGRES_PASSWORD }}
          POSTGRES_USER : ${{ secrets.POSTGRES_USER }}
          POSTGRES_DB : ${{ secrets.POSTGRES_DB }}
      - name: build image
        run: docker build . --file db/dockerfile --tag postgres_db
      - name: run image
        run: docker run -d -p 5432:5432 --name postgres_container1 postgres_db sleep 100
  lint_build:
    name: Lint Code Base 
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3
        with:
          fetch-depth: 0
      - name: Lint Code Base
        uses: github/super-linter@v4
        env:
          VALIDATE_ALL_CODEBASE: false
          DEFAULT_BRANCH: main
          GITHUB_TOKEN: ${{ secrets.TOKEN }}
```
**CI/CD pipeline successfully done**
![Screenshot (97)](https://user-images.githubusercontent.com/65711565/229647206-57065e42-92d0-4568-bc61-d6f8271c46d8.png)
**Successfully deployed to AWS runner**
![Screenshot (98)](https://user-images.githubusercontent.com/65711565/229647425-3a7ae5df-4baf-433a-a315-c896741cedb6.png)
### Output
![Screenshot (100)](https://user-images.githubusercontent.com/65711565/229653750-746d503e-289d-429b-b418-fe642c6b079a.png)

