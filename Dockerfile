FROM alpine:3.4

RUN apk update && \
  apk add \
    ca-certificates \
    git \
    bash && \
  rm -rf /var/cache/apk/*

ADD git.sh /bin/
RUN chmod +x /bin/git.sh

ENTRYPOINT ["/bin/git.sh"]
