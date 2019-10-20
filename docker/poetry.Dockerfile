ARG PYTHON_TAG

FROM python:${PYTHON_TAG} AS base

ARG PYTHON_TAG
ARG PIP_VERSION
ARG POETRY_VERSION

LABEL org.opencontainers.image.authors="<pablowoolvett@gmail.com>"
LABEL org.opencontainers.image.url=https://github.com/pwoolvett/dockers
LABEL org.opencontainers.image.documentation=https://github.com/pwoolvett/dockers
LABEL org.opencontainers.image.source=https://github.com/pwoolvett/dockers
LABEL org.opencontainers.image.licenses=UNLICENSE
LABEL org.opencontainers.image.title="Base Dockerfile with poetry"
LABEL org.opencontainers.image.description="Use this image as base to build incrementally"
LABEL pw.devx.python.VERSION=$PYTHON_VERSION
LABEL pw.devx.python.PIP_VERSION=$PYTHON_PIP_VERSION
LABEL pw.devx.python.POETRY_VERSION=$POETRY_VERSION

ENTRYPOINT [ "sh" ]

RUN pip install pip==${PIP_VERSION}

ADD https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py ./
RUN python get-poetry.py \
        --force \
        --yes \
        --preview \
        --version $POETRY_VERSION \
    && rm get-poetry.py
ENV PATH="/root/.poetry/bin:$PATH"
# bug: poetry wont auto-create stuff
RUN mkdir -p /root/.config/pypoetry/ \
    && touch /root/.config/pypoetry/config.toml \
    && poetry config virtualenvs.create false

WORKDIR /app
COPY app /app
RUN python -c \
    "from string import Template;\
    from os import environ;\
    t1=open('pyproject.toml.template').read();\
    t2=Template(t1).substitute(PYTHON_VERSION=environ['PYTHON_VERSION']);\
    open('pyproject.toml','w').write(t2)" \
    && rm pyproject.toml.template

ARG VCS_REF
LABEL org.opencontainers.image.revision=$VCS_REF

ARG BUILD_DATE
LABEL org.opencontainers.image.created=$BUILD_DATE


# RUN apk add \
#     --no-cache \
#     --update \
#     python3-dev \
#     gcc \
#     build-base \
#     libressl-dev \
#     musl-dev \
#     libffi-dev
# RUN pip install --upgrade pip
# WORKDIR /app

# FROM base as poetry

# ARG PYTHON_VERSION=3.6
# ARG POETRY_VERSION=1.0.0a5

# LABEL PYTHON_VERSION=${PYTHON_VERSION}
# LABEL POETRY_VERSION=${POETRY_VERSION}

# COPY get-poetry.py .
# RUN python get-poetry.py

# RUN python get-poetry.py --preview --version ${POETRY_VERSION}
# RUN rm get-poetry.py
# ENV PATH="/root/.poetry/bin:${PATH}"

# RUN mkdir -p /root/.config/pypoetry/
# RUN touch /root/.config/pypoetry/config.toml

# RUN poetry config settings.virtualenvs.create false
# RUN poetry config repositories.ICPyPI https://iccorpiconstruye.pkgs.visualstudio.com/_packaging/ICPyPI/pypi/simple/
# # BUG: poetry config wont always write the input correctly into auth.toml!!!
# # RUN poetry config http-basic.ICPyPI ICPyPI y4lohaaugz2qz3gvoqxifkvekmiuj6h2zzsoxxutrwl2zqxppwhq
# # workaround:  Manually edit auth.toml
# RUN echo -e \
#       '[http-basic]'\
#       '\n[http-basic.ICPyPI]'\
#       '\npassword = "y4lohaaugz2qz3gvoqxifkvekmiuj6h2zzsoxxutrwl2zqxppwhq"'\
#       '\nusername = "ICPyPI"\n'\
#       > /root/.config/pypoetry/auth.toml

# ENTRYPOINT [ "sh" ]
