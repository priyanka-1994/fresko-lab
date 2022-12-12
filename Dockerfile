FROM python:3.8

RUN pip3 install pipenv

ENV Fresko-pvt-ltd /usr/src

WORKDIR ${Fresko-pvt-ltd}

COPY Procfile .

COPY todo.db .

COPY requirements.txt .

COPY . .

RUN pipenv install --deploy --ignore-pipfile

EXPOSE 5000

CMD ["pipenv", "run", "python", "app.py"]