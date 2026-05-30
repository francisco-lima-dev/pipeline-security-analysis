FROM python:3.12-slim

WORKDIR /workspace

RUN apt-get update && apt-get install -y git curl 

RUN pip3 install --break-system-packages semgrep

COPY scripts/ /scripts/

RUN chmod +x /scripts/*.sh

ENTRYPOINT ["/scripts/run_semgrep.sh"]

