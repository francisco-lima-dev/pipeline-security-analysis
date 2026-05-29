FROM debian:bookworm-slim

WORKDIR /workspace

RUN apt-get update && apt-get install -y \
    git \
    curl \
    python3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://static.snyk.io/cli/latest/snyk-linux -o /usr/local/bin/snyk \
    && chmod +x /usr/local/bin/snyk

COPY scripts/ /scripts/

RUN chmod +x /scripts/*.sh

ENTRYPOINT ["/scripts/run_snyk.sh"]
