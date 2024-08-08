# variable
ARG PYTHON_VERSION=3.12

# library build stage
FROM python:${PYTHON_VERSION} AS requirements-stage

WORKDIR /tmp

RUN pip install poetry
COPY ./pyproject.toml ./poetry.lock* /tmp/
RUN poetry export -f requirements.txt --output requirements.txt --without-hashes

# app packaging stage
FROM python:${PYTHON_VERSION}

COPY . /app
WORKDIR /app
COPY --from=requirements-stage /tmp/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir --upgrade -r /app/requirements.txt
RUN python -m compileall src

# for FastAPI on Google Cloud Run
EXPOSE 8080
CMD uvicorn src.app:app --host=0.0.0.0 --port=8080
