FROM debian:stable-slim as builder

ARG KUBECTL_VERSION=v1.29.2

RUN apt-get update && \
    apt-get install -y -q bash curl unzip

WORKDIR /opt/awscli

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

WORKDIR /opt/kubectl

RUN curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl" && \
    chmod 705 kubectl && \
    curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl.sha256" && \
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

FROM debian:stable-slim

WORKDIR /app

COPY --from=builder /opt/kubectl /usr/local/bin/aws /usr/local/bin/

RUN adduser refresher --disabled-login --disabled-password --system --group && \
    chown -R refresher:refresher /app

USER refresher

COPY refresh.sh .

CMD ["./refresh.sh"]

