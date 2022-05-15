#!/bin/bash

# Start duration timer
timeEllapsed="$(date +%s)"

# Input options
domain=${domain:-".test"}
help=${help:-false}

# Variables
helpoptionsrows="\n  --%-30s %-40s"

# Light green background with black text
function greenBackground {
  echo "\e[0;102;30m $1 \e[0m"
}

# Light purple background with black text
function purpleBackground {
  echo "\e[0;105;30m $1 \e[0m"
}

# Light yellow background with black text
function yellowBackground {
  echo "\e[0;103;30m $1 \e[0m"
}


# Display helpful information.
function helpText {
  printf "\nUsage: ./create-host-resolver.sh [flags]\n"

  printf "\nOptions:\n"
  printf "$helpoptionsrows" "--domain" "The domain to configure."
  printf "$helpoptionsrows" "--help" "Display helpful information."

  printf "\n\n"
}

# Print the script duration time
function timeDuration {
  timeEllapsed="$(($(date +%s)-$timeEllapsed))"
  printf "\n\nDuration: ${timeEllapsed} seconds."
}

function configureDomain {
  # Configure local TLD
  # MacOS only
  if [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ ! -f /etc/resolver/$domain ]]; then
      printf "\n$(yellowBackground "$domain needs configuring")\n\n"
      printf "The domain '$domain' has not yet been configured on this mac.\n\nTo configure the domain please authorize sudo access.\n\n"

      if [[ ! -d /etc/resolver ]]; then
        sudo mkdir /etc/resolver
        exitCode=$?
      fi

      echo "nameserver 127.0.0.1" | sudo tee /etc/resolver/$domain >/dev/null
      exitCode=$?

      printf "\n\n$(greenBackground "$domain is ready to use 🎉")\n\n"
    else
      printf "\n\n$(greenBackground "$domain is already configured 🎉")\n\n"
    fi
  else
    warning "You need to manually configure $domain"
  fi
}

# 1. Set up flags and variables
while [ $# -gt 0 ]; do
  if [[ $1 == *"--"* ]]; then
    param="${1/--/}"

    if [[ $2 = "" || $2 == *"--"* ]]; then
      declare $param=true
    else
      declare $param="$2"
    fi
  fi

  shift
done

configureDomain
timeDuration

exit $exitCode
