FROM golang:1.24.3-alpine3.22 AS build

RUN apk add --no-cache make git

WORKDIR /go/src/github.com/serbushevm/object-browser

# Building stuff
COPY . /go/src/github.com/serbushevm/object-browser
RUN make console

FROM alpine:3.22
RUN adduser -D -u 1000 console

RUN apk add --no-cache ca-certificates
COPY --from=build /go/src/github.com/serbushevm/object-browser/console /usr/local/bin/console

USER console
CMD ["console", "server"]