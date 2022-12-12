FROM python:3.8

RUN pip install flask-sqlalchemy

RUN pip3 install pipenv

RUN pip install Flask

ENV Fresko-pvt-ltd /usr/src/todoapp

#WORKDIR ${Fresko-pvt-ltd}

#COPY Procfile .

COPY todo.db .

COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["pipenv","run", "app.py", "--host=0.0.0.0"]


# FROM python:3.8

# RUN pip install flask-sqlalchemy

# RUN pip3 install pipenv

# <<<<<<< HEAD
# ENV Fresko-pvt-ltd /usr/src
# =======
# ENV Fresko-pvt-ltd /usr/src/todoapp
# >>>>>>> c33e2937c3e504233b62e6d02bf31ee76fa4e424

# WORKDIR ${Fresko-pvt-ltd}

# COPY Procfile .

# COPY todo.db .

# COPY requirements.txt .

# COPY . .

# RUN pipenv install --deploy --ignore-pipfile

# EXPOSE 5000

# CMD ["pipenv", "run", "python", "app.py"]
