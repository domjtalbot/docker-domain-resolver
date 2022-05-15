# Set the alpine version used by the image
ARG ALPINE_VERSION=edge

FROM alpine:$ALPINE_VERSION

# Set the default values used by env variables

ARG DEFAULT_DOMAIN=test

# Default to Cloudflare DNS
ARG DEFAULT_NS1=1.0.0.1
ARG DEFAULT_NS2=1.1.1.1

ARG DEFAULT_ADDITIONAL_CONFIG=#

# Define env variables required for configuring dnsmasq

ENV DOMAIN=$DEFAULT_DOMAIN
ENV NS1=$DEFAULT_NS1
ENV NS2=$DEFAULT_NS2
ENV ADDITIONAL_CONFIG=$DEFAULT_ADDITIONAL_CONFIG

# Install dnsmasq
RUN apk --no-cache add dnsmasq-dnssec

# Configure global dnsmasq
RUN mkdir -p /etc/default/ && \
  echo -e "ENABLED=1\nIGNORE_RESOLVCONF=yes" \
  > /etc/default/dnsmasq

# Configure resolvers
RUN mkdir -p /etc/resolver

# Setup the entrypoint script
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

EXPOSE 53 53/udp

ENTRYPOINT ["/entrypoint.sh"]
