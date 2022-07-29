ARG DOCKER_VERSION=latest
FROM docker:${DOCKER_VERSION}
ARG KUBECTL_VERSION=v1.24.3
ARG SOPS_VERSION=v3.7.3
ARG AGE_VERSION=v1.0.0
ARG COMPOSE_VERSION=1.29.2
ARG DOCTL_VERSION=1.78.0

RUN apk add --no-cache py3-pip python3 curl git openssl go bash
RUN apk add --no-cache --virtual \
  build-dependencies \
  cargo \
  gcc \
  libc-dev \
  libffi-dev \
  make \
  openssl-dev \
  python3-dev \
  rust \
  && pip3 install "docker-compose${COMPOSE_VERSION:+==}${COMPOSE_VERSION}" \
  && apk del build-dependencies

RUN curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && chmod +x kubectl && mv kubectl /usr/local/bin/kubectl
RUN curl -LO "https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-amd64.tar.gz" && tar xf doctl-${DOCTL_VERSION}-linux-amd64.tar.gz && mv doctl /usr/local/bin/doctl
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && chmod +x get_helm.sh && ./get_helm.sh
RUN helm plugin install https://github.com/databus23/helm-diff && \
  helm plugin install https://github.com/jkroepke/helm-secrets
RUN curl -L -o sops "https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.amd64" && chmod +x sops && mv sops /usr/local/bin/sops
RUN curl -LO "https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-linux-amd64.tar.gz" \
  && tar -zxvf age-${AGE_VERSION}-linux-amd64.tar.gz \
  && cp age/age /usr/local/bin/age \
  && cp age/age-keygen /usr/local/bin/age-keygen \
  && rm -rf age get_helm.sh age-${AGE_VERSION}-linux-amd64.tar.gz

LABEL \
  org.opencontainers.image.authors="Zen Kyprianou <hello@factory39.io>" \
  org.opencontainers.image.description="This image install docker-compose ontop of Docker as well as Kubectl, Helm with some plugins for use in CI builds" \
  org.opencontainers.image.licenses="MIT" \
  org.opencontainers.image.source="https://gitlab.com/factory39/k8s-builder-deployer" \
  org.opencontainers.image.title="Docker Compose, Kubectl, Helm on docker base image" \
  org.opencontainers.image.vendor="Factory 39" \
  org.opencontainers.image.version="${KUBECTL_VERSION} with ${HELM_VERSION} and ${DOCKER_VERSION} with docker-compose ${COMPOSE_VERSION}"
