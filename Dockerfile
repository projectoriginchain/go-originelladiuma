# Build Gprog in a stock Go builder container
FROM golang:1.12-alpine as builder

RUN apk add --no-cache make gcc musl-dev linux-headers git

ADD . /go-originelladiuma
RUN cd /go-originelladiuma && make gprog

# Pull Gprog into a second stage deploy alpine container
FROM alpine:latest

RUN apk add --no-cache ca-certificates
COPY --from=builder /go-originelladiuma/build/bin/gprog /usr/local/bin/

EXPOSE 7996 7997 47380 47380/udp
ENTRYPOINT ["gprog"]
