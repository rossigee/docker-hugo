# Build Hugo binary
FROM ubuntu:noble AS hugobuild
ENV HUGO_VERSION=v0.148.2
RUN apt-get update && \
    apt-get install -y wget git g++
RUN wget https://go.dev/dl/go1.25.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.25.0.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin
WORKDIR /root
RUN CGO_ENABLED=1 go install -tags extended github.com/gohugoio/hugo@${HUGO_VERSION}

# Build into a release container
FROM ubuntu:noble
ENV PATH=$PATH:/usr/local/bin
COPY --from=hugobuild /root/go/bin/hugo /usr/bin/hugo