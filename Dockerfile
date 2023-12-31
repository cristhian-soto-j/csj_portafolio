FROM python:3.6

ENV PYTHONUNBUFFERED 1
RUN mkdir -p /opt/services/djangoapp/src

COPY Pipfile Pipfile.lock /opt/services/djangoapp/src/
WORKDIR /opt/services/djangoapp/src
RUN apt-get update && apt-get install -y python3 python3-pip
RUN pip install pipenv && pipenv install --system

RUN pip install psycopg2-binary

# COPY base.py base.py

# RUN python base.py


COPY . /opt/services/djangoapp/src
RUN cd core && python manage.py collectstatic --no-input
#RUN cd core && for db in default && do ./manage.py migrate --database=$${db} && done


EXPOSE 8000
CMD ["gunicorn", "-c", "gunicorn/conf.py", "--bind", "0.0.0.0:8000", "--chdir", "core", "core.wsgi:application"]