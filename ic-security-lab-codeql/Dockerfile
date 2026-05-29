FROM node:24-bookworm

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

RUN curl -L -o codeql-bundle.tar.gz \
    https://github.com/github/codeql-action/releases/download/codeql-bundle-v2.25.4/codeql-bundle-linux64.tar.gz \
    && tar -xzf codeql-bundle.tar.gz -C /opt \
    && rm codeql-bundle.tar.gz

ENV PATH="/opt/codeql:${PATH}"

COPY scripts/ /scripts/

RUN chmod +x /scripts/*.sh

ENTRYPOINT ["/scripts/run_codeql.sh"]

