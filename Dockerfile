FROM golang:1.11-alpine AS builder

RUN apk update
RUN apk add --no-cache ca-certificates glide git

WORKDIR /go/src/github.com/e-travel/cloudwatchlogsbeat
COPY glide.yaml glide.lock ./
RUN glide install

COPY cwl cwl
COPY beater beater
COPY main.go .
RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -i -o cloudwatchlogsbeat

FROM scratch

ARG BEAT_HOME="/usr/share/cloudwatchlogsbeat"

ENV PATH="${BEAT_HOME}:${PATH}"

COPY --from=builder /go/src/github.com/e-travel/cloudwatchlogsbeat/cloudwatchlogsbeat "${BEAT_HOME}/cloudwatchlogsbeat"
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
WORKDIR "${BEAT_HOME}"

CMD ["cloudwatchlogsbeat"]