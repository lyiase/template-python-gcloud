# variable
ARG PYTHON_VERSION=3.14

FROM ghcr.io/astral-sh/uv:0.12.5 AS uv

FROM python:${PYTHON_VERSION}
COPY --from=uv /uv /uvx /bin/

WORKDIR /app

# set locale
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# set env : TimeZone
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# set env : python workdirs
ENV PYTHONPATH=/app
ENV PATH="/app/.venv/bin:$PATH"
#ENV HF_HOME=/app/.tf

# install python libraries
COPY pyproject.toml uv.lock ./
RUN uv sync --locked --no-install-project
COPY . .
RUN uv sync --locked
RUN python -m compileall src

RUN useradd -r python

# set run user permission
RUN chown -R python:python .

USER python

# for FastAPI on Google Cloud Run
EXPOSE 8080
CMD ["uvicorn", "src.app:app", "--host", "0.0.0.0", "--port", "8080"]
