# variable
ARG PYTHON_VERSION=3.13

# library build stage
FROM python:${PYTHON_VERSION} AS requirements-stage
#FROM huggingface/transformers-pytorch-cpu:latest AS requirements-stage

WORKDIR /tmp

RUN pip install poetry && pip install poetry-plugin-export
COPY ./pyproject.toml ./poetry.lock* /tmp/
RUN poetry export -f requirements.txt --output requirements.txt --without-hashes

# app packaging stage
FROM python:${PYTHON_VERSION}
#FROM huggingface/transformers-pytorch-cpu:latest

# set locale
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# set env : TimeZone
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# set env : python workdirs
ENV PYTHONPATH=/app
#ENV HF_HOME=/app/.tf

# install python libraries
COPY . /app
WORKDIR /app
COPY --from=requirements-stage /tmp/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir --upgrade -r /app/requirements.txt
RUN python -m compileall src

RUN useradd -r python

# set run user permission
RUN chown -R python:python .
COPY --chown=python . .

USER python

# for FastAPI on Google Cloud Run
EXPOSE 8080
CMD ["uvicorn", "src.app:app", "--host", "0.0.0.0", "--port", "8080"]
