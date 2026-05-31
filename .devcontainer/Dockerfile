# Flutter SDK pin — align with .fvm/fvm_config.json and CI
ARG FLUTTER_VERSION=3.35.6
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_VERSION=${FLUTTER_VERSION}
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="${FLUTTER_HOME}/bin:${PATH}"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/flutter/flutter.git -b "${FLUTTER_VERSION}" --depth 1 "${FLUTTER_HOME}" \
    && flutter config --no-analytics \
    && flutter precache --web \
    && flutter doctor -v

WORKDIR /workspace
