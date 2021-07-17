# build step
FROM python:3.9-slim-buster as build
WORKDIR /usr/src

COPY ./pyproject.toml /usr/src/pyproject.toml
COPY ./poetry.lock /usr/src/poetry.lock

RUN apt update \
  && apt install -y --no-install-recommends \
    gcc \
    libmariadb-dev \
  && apt clean \
  && rm -rf /var/lib/apt/lists/* \
  && pip install --upgrade pip setuptools wheel \
  && pip install poetry uwsgi \
  && poetry config virtualenvs.create false \
  && poetry config virtualenvs.in-project true \
  && poetry install --no-dev \
  && rm -rf ~/.cache


# runner
FROM python:3.9-slim-buster as deploy
ENV PYTHONUNBUFFERED=1
WORKDIR /usr/src

RUN apt update \
  && apt install -y --no-install-recommends libmariadb-dev \
  && apt clean \
  && rm -rf /var/lib/apt/lists* \
  && useradd -r -s /bin/false docker

COPY --from=build /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=build /usr/local/bin/uwsgi /usr/local/bin/uwsgi
COPY ./ /usr/src

USER docker
EXPOSE 8000
CMD uwsgi --ini uwsgi.ini
