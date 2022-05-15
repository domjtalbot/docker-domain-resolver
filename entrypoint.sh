#!/bin/sh

# -------------------------------------
# Functions
# -------------------------------------

# Green Text
function green {
  echo "\033[0;32m$1\033[0m"
}

# Yellow Text
function red {
  echo "\033[0;31m$1\033[0m"
}

# Yellow Text
function yellow {
  echo "\033[1;33m$1\033[0m"
}

# dnsmasq config
# http://oss.segetech.com/intra/srv/dnsmasq.conf
function createDNSMasqConfig {
  printf "\n  Creating dnsmasq config...\n"

  (echo "log-queries" && \
    echo "no-resolv" && \
    echo "server=$NS1" && \
    echo "server=$NS2" && \
    echo "strict-order" && \
    echo "address=/$DOMAIN/127.0.0.1" && \
    echo "$ADDITIONAL_CONFIG") \
    > /etc/dnsmasq.conf

  printf "    $(green "✓") dnsmasq config created."
}

# Check if the host has a resolver for the domain
function checkDNSResolver {
  printf "\n  Checking dns resolver...\n"

  if [[ ! -f /etc/resolver/$DOMAIN ]]; then
    printf "    $(red "✗ The resolver for $DOMAIN doesn't exist.")"
    printf "\n      $(red "You need to configure the resolver on the host machine first.")\n\n"
    exit 0
  else
    printf "    $(green "✓") dns resolver exists.\n"
  fi
}


# -------------------------------------
# Workflow
# -------------------------------------

printf "$(yellow "Configuring $DOMAIN...")\n"

checkDNSResolver
createDNSMasqConfig

printf "\n\n\n$(green "$DOMAIN is ready to use! 🎉 🖖")\n"

/usr/sbin/dnsmasq -k
