ARG BASE_TAG

FROM pwoolvett/poetry:$BASE_TAG as builder

ARG PSYCOPG2_VERSION

RUN apk add --no-cache --virtual .build-deps \
    gcc \
    python3-dev \
    musl-dev \
    postgresql-dev \
    && pip install \
        --no-cache-dir \
        psycopg2==$PSYCOPG2_VERSION \
    && apk del --no-cache .build-deps

FROM pwoolvett/poetry:$BASE_TAG as postgres

RUN apk --no-cache add libpq

COPY --from=builder /usr/local/lib/python3.* /tmp/python_site_pkgs/
RUN mv /tmp/python_site_pkgs/site-packages/psycopg2* \
    $(python -c \
        "from sys import path as p; \
         print([a for a in p if 'site-packages' in a][0]) \
     ")

ARG PSYCOPG2_VERSION
LABEL pw.devx.python.PSYCOPG2_VERSION=$PSYCOPG2_VERSION
