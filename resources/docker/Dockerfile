FROM golang:1.22 AS build

ENV CGO_ENABLED=0
ENV GOOS=linux
RUN useradd -u 10001 bento

WORKDIR /go/src/github.com/kmpm/bento-custom/
# Update dependencies: On unchanged dependencies, cached layer will be reused
COPY go.* /go/src/github.com/kmpm/bento-custom/
RUN go mod download

# Build
COPY . /go/src/github.com/kmpm/bento-custom/
# Tag timetzdata required for busybox base image:
# https://github.com/warpstreamlabs/bento/issues/897
RUN make TAGS="timetzdata" && ls -lah target

# Pack
FROM busybox AS package

LABEL maintainer="Peter Magnusson <me@kmpm.se>"
LABEL org.opencontainers.image.source="https://github.com/kmpm/bento-custom"

WORKDIR /

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /etc/passwd /etc/passwd
COPY --from=build /go/src/github.com/kmpm/bento-custom/target/bento .
COPY ./resources/config/docker.yml /bento.yml

USER bento

EXPOSE 4195

ENTRYPOINT ["/bento"]

CMD ["-c", "/bento.yml"]
