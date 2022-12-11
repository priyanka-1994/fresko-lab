FROM python:3.8

RUN pip3 install pipenv

ENV PROJECT_DIR /usr/src/todoapp

WORKDIR ${PROJECT_DIR}

COPY Procfile .

#COPY Pipfile.lock .

COPY . .

RUN pipenv install --deploy --ignore-pipfile

EXPOSE 5000

CMD ["pipenv", "run", "python", "app.py"]
