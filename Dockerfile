# ─────────────────────────────── build stage ────────────────────────────────
FROM golang:1.24.3-alpine3.22 AS build

RUN apk add --no-cache make git

WORKDIR /go/src/github.com/serbushevm/object-browser

# Building stuff
COPY . /go/src/github.com/serbushevm/object-browser
RUN make console

# ────────────────────────────── runtime stage ───────────────────────────────
FROM alpine:3.22

# GitHub Buildx passes the target architecture in this ARG automatically
ARG TARGETARCH            # e.g. amd64 or arm64

# 1) create an unprivileged user
RUN adduser -D -u 1000 console

# 2) base utilities
RUN apk add --no-cache ca-certificates wget

# 3) download the official MinIO Client binary matching the build architecture
RUN wget -q -O /usr/local/bin/mc \
        "https://dl.min.io/client/mc/release/linux-${TARGETARCH}/mc" && \
    chmod +x /usr/local/bin/mc

# 4) your compiled Go CLI
COPY --from=build /go/src/github.com/serbushevm/object-browser/console /usr/local/bin/console

USER console
CMD ["console", "server"]