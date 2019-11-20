FROM alpine:3.10

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/mintel/docker-restic-cron.git" \
      org.label-schema.schema-version="1.0.0-rc1" \
      org.label-schema.name="restic-cron" \
      org.label-schema.description="An image with Restic and Superchronic installed, intended to be used as a base for specific backup jobs" \
      org.label-schema.vendor="Mintel LTD" \
      maintainer="Francesco Ciocchetti <fciocchetti@mintel.com>"


ENV RESTIC_VERSION="0.9.5" \
    RESTIC_SHA512="c040dfe9c73a0bc8de46ccdf4657c9937b27a3c1bd25941f40c9efd1702994f54e79f077288e626a5841fbf9bbf642b6d821628cf6b955d88b97f07e5916daac" \
    SUPERCRONIC_VERSION="0.1.9" \
    SUPERCRONIC_SHA512="a1678fcec4182b675c48296cbfc0866a97a737c4ce1b7b59ad36b3cb587d47fa9c7141e9cba07837579605631bc1b0e15afaabb87d26f8b6571a788713896796"
    
  # Install Let's Encrypt Staging CA so that we can connect "securely"
RUN apk update \
  && apk --no-cache upgrade \
  && apk --no-cache add ca-certificates wget bash jq coreutils \
  && wget -O /usr/local/share/ca-certificates/fakelerootx1.crt https://letsencrypt.org/certs/fakelerootx1.pem \
  && wget -O /usr/local/share/ca-certificates/fakeleintermediatex1.crt https://letsencrypt.org/certs/fakeleintermediatex1.pem \
  && update-ca-certificates \
  && rm -rf /var/cache/apk/*

# Install restic and superchronic
RUN wget -O /tmp/restic-${RESTIC_VERSION}.bz2 "https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_amd64.bz2" \
  && wget -O /tmp/supercronic "https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-amd64" \
  && cd /tmp \
  && echo "${RESTIC_SHA512}  restic-${RESTIC_VERSION}.bz2" | sha512sum -c - \
  && echo "${SUPERCRONIC_SHA512}  supercronic" | sha512sum -c - \
  && bunzip2 -c restic-${RESTIC_VERSION}.bz2 > /usr/local/bin/restic \
  && mv supercronic /usr/local/bin \
  && chmod a+x /usr/local/bin/supercronic \
  && chmod a+x /usr/local/bin/restic

# In case you want to run this as a Kubernetes Cronjob to make sure only one is running at any time add kubelock
COPY --from=mintel/kubelock:0.1.0 /usr/local/bin/kubelock /usr/local/bin/

ADD rootfs/ /

RUN adduser -D -s /bin/bash mintel

ADD docker-entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

USER mintel
ENTRYPOINT ["/entrypoint.sh"]
