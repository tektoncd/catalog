FROM alpine

RUN apk update \
 && apk upgrade \
 && apk add --no-cache \
            rsync \
            openssh-client \
            openssh \
            sshpass \
            ca-certificates \
 && update-ca-certificates \
 && rm -rf /var/cache/apk/*