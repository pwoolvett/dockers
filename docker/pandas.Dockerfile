ARG BASE_TAG

FROM pwoolvett/poetry:$BASE_TAG as builder

ARG PANDAS_VERSION

RUN apk add --no-cache \
    --virtual=.build-dependencies \
    g++ gfortran file binutils \
    musl-dev python3-dev openblas-dev && \
    apk add libstdc++ openblas && \
    \
    ln -s locale.h /usr/include/xlocale.h && \
    \
    pip install pandas==$PANDAS_VERSION && \
    \
    rm -r /root/.cache && \
    find /usr/lib/python3.*/ -name 'tests' -exec rm -r '{}' + && \
    find /usr/lib/python3.*/site-packages/ -name '*.so' -print -exec sh -c 'file "{}" | grep -q "not stripped" && strip -s "{}"' \; && \
    \
    rm /usr/include/xlocale.h && \
    \
    apk del .build-dependencies

FROM pwoolvett/poetry:$BASE_TAG as pandas

RUN apk add --no-cache openblas libstdc++

COPY --from=builder /usr/local/lib/python3.* /tmp/python_site_pkgs/


RUN mv /tmp/python_site_pkgs/site-packages/pandas* \
    $(python -c \
    "from sys import path as p; \
    print([a for a in p if 'site-packages' in a][0])")

RUN mv /tmp/python_site_pkgs/site-packages/numpy* \
    $(python -c \
    "from sys import path as p; \
    print([a for a in p if 'site-packages' in a][0])")

RUN mv /tmp/python_site_pkgs/site-packages/pytz* \
    $(python -c \
    "from sys import path as p; \
    print([a for a in p if 'site-packages' in a][0])")

RUN mv /tmp/python_site_pkgs/site-packages/dateutil* \
    $(python -c \
    "from sys import path as p; \
    print([a for a in p if 'site-packages' in a][0])")

RUN mv /tmp/python_site_pkgs/site-packages/six* \
    $(python -c \
    "from sys import path as p; \
    print([a for a in p if 'site-packages' in a][0])")

ARG PANDAS_VERSION
LABEL pw.devx.python.PANDAS_VERSION=$PANDAS_VERSION
