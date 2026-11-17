FROM python:3.12-slim-bookworm AS build

ENV PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /build

RUN apt-get update \
    && apt-get install --no-install-recommends --yes gcc \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN python -m pip install --prefix=/install -r requirements.txt

FROM python:3.12-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN useradd --create-home --uid 10001 --shell /usr/sbin/nologin appuser

COPY --from=build /install /usr/local
COPY --chown=appuser:appuser . .

USER appuser

EXPOSE 4000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "from urllib.request import urlopen; urlopen('http://127.0.0.1:4000/', timeout=3)"

CMD ["python", "main.py"]
