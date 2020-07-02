# prod.Dockerfile
# Reference: https://martinheinz.dev/blog/17
# Changed builder & runner images sources only

FROM debian:buster-slim AS builder
RUN apt-get update && apt-get install -y --no-install-recommends --yes python3-venv gcc libpython3-dev && \
    python3 -m venv /venv && \
    /venv/bin/pip install --upgrade pip

FROM builder AS builder-venv

COPY requirements.txt /requirements.txt
RUN /venv/bin/pip install -r /requirements.txt

FROM builder-venv AS tester

COPY . /app
WORKDIR /app
RUN /venv/bin/pytest


# Distroless = set of images made by Google that contain bare minimum needed for application.
# No shells, package managers, or other bloating tools that create signal noise for security scanners.
# NOTE: No shell means you can't debug. If you need to debug PROD, do the following, use debug tag.
# > docker run --entrypoint=sh -ti gcr.io/distroless/python3-debian10:debug
FROM gcr.io/distroless/python3-debian10 AS runner
COPY --from=tester /venv /venv
COPY --from=tester /app /app

WORKDIR /app

ENTRYPOINT ["/venv/bin/python3", "-m", "blueprint"]
USER 1001

LABEL name={NAME}
LABEL version={VERSION}
