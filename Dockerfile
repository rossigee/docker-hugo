# Build Hugo binary
FROM ubuntu:resolute AS hugobuild
ARG TARGETARCH
ENV HUGO_VERSION=v0.161.1
ENV GO_VERSION=1.26.3
RUN apt-get update && \
    apt-get install -y wget git g++
RUN if [ "$TARGETARCH" = "arm64" ]; then \
        GO_ARCH="arm64"; \
    else \
        GO_ARCH="amd64"; \
    fi && \
    wget https://go.dev/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-${GO_ARCH}.tar.gz
ENV PATH=$PATH:/usr/local/go/bin
WORKDIR /root
RUN CGO_ENABLED=1 go install -tags extended github.com/gohugoio/hugo@${HUGO_VERSION}

# Build into a release container
FROM ubuntu:resolute
ENV PATH=$PATH:/usr/local/bin
COPY --from=hugobuild /root/go/bin/hugo /usr/bin/hugo
