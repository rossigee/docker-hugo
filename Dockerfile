# Build Hugo binary
FROM --platform=$TARGETPLATFORM ubuntu:resolute AS hugobuild
ARG TARGETARCH
ENV HUGO_VERSION=v0.161.1
RUN apt-get update && \
    apt-get install -y wget && \
    rm -rf /var/lib/apt/lists/*
RUN if [ "$TARGETARCH" = "arm64" ]; then \
        HUGO_ARCH="arm64"; \
    else \
        HUGO_ARCH="amd64"; \
    fi && \
    wget -O hugo.tar.gz "https://github.com/gohugoio/hugo/releases/download/${HUGO_VERSION}/hugo_extended_${HUGO_VERSION#v}_linux-${HUGO_ARCH}.tar.gz" && \
    tar -xf hugo.tar.gz hugo && \
    mv hugo /usr/bin/hugo && \
    chmod +x /usr/bin/hugo

# Build into a release container
FROM --platform=$TARGETPLATFORM ubuntu:resolute
ENV PATH=$PATH:/usr/local/bin
COPY --from=hugobuild /usr/bin/hugo /usr/bin/hugo
