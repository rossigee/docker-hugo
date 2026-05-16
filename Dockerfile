# Build Hugo binary
FROM ubuntu:resolute AS hugobuild
ENV HUGO_VERSION=v0.161.1
RUN apt-get update && \
    apt-get install -y wget git g++
RUN wget https://go.dev/dl/go1.26.3.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.26.3.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin
WORKDIR /root
RUN CGO_ENABLED=1 go install -tags extended github.com/gohugoio/hugo@${HUGO_VERSION}

# Build into a release container
FROM ubuntu:resolute
ENV PATH=$PATH:/usr/local/bin
COPY --from=hugobuild /root/go/bin/hugo /usr/bin/hugo
