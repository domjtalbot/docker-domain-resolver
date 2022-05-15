<br/>

<h1 align="center">Domain Resolver</h1>

<p align="center">🐳 A minimal config domain resolver for Docker.</p>

<div align="center">
  <p dir="auto">
    <a href="https://hub.docker.com/r/domjtalbot/domain-resolver">
      <img src="https://img.shields.io/docker/image-size/domjtalbot/domain-resolver/latest?style=flat&logoColor=white&logo=docker" alt="Docker Image size" />
    </a>
    <a href="https://github.com/sponsors/domjtalbot">
      <img src="https://img.shields.io/badge/Sponsor @domjtalbot-30363D?style=flat&logo=GitHub-Sponsors&logoColor=#EA4AAA" alt="Sponsor @domjtalbot on GitHub!" />
    </a>
  </p>
</div>

<br/>

## Why?

Custom local domains are a great tool when developing software, but their set-up steps can be tedious and often forgotten.

This Docker image automates part of the process of setting up a local domain so that you can focus on your development.

<br/>

## How does it work?

There are three parts to setting up a local domain with Docker:

1. Create a resolver on the Host machine.
2. Direct traffic from the Host machine to other Docker services.
3. Define a server service to use the domain.

The `domain-resolver` Docker image is responsible for step 2, directing traffic from the Host machine to other Docker services.

<br/>

## How to use

The `domain-resolver` docker image is available from both [GitHub Container Registry (GHCR)](https://github.com/domjtalbot/docker-domain-resolver/pkgs/container/domain-resolver) and [Docker Hub](https://hub.docker.com/r/domjtalbot/domain-resolver).

### Docker Compose

Add the following service to your `docker-compose.yml` config:

```yaml
services:
  domain-resolver:
    container_name: domain-resolver

    # GitHub Container Registry (GHCR)
    # image: ghcr.io/domjtalbot/domain-resolver

    # Docker Hub
    image: domjtalbot/domain-resolver

    environment:
      # The domain you want to resolve
      # (Defaults to `test`)
      - DOMAIN=example.dockerdomainresolver

      # Cutom DNS servers
      # (Defaults to Cloudflare)
      # - NS1=1.0.0.1
      # - NS2=1.1.1.1

      # Add additional config for dnsmasq
      # (Defaults to #)
      # - ADDITIONAL_CONFIG=#
    ports:
      - "127.0.0.1:53:53/udp"
    volumes:
      # Allow domain-resolver to check if the
      # domain has been configured on the host.
      - /etc/resolver:/etc/resolver:ro
    restart: always
```

You can then run Docker compose using:

```bash
docker-compose up -d
```

> This presumes a resolver already exists on the Host machine. See the next step for automating the creation of a resolver on the Host machine.

### Create a resolver on the Host machine

To help automate the creation of a resolver on the Host machine, you can use the `create-host-resolver` script.

```bash
./create-host-resolver.sh --domain example.dockerdomainresolver
```

> Please note that the process of creating a resolver varies depending on the type of Host. The `create-host-resolver` script currently only supports macOS.

<br/>

## Full Example

A full example using Caddy as the server service.

### Example directory

```bash
.env
Caddyfile
create-host-resolver.sh
docker-compose.yml
```

### File contents

`.env`

```bash
DOCKER_DOMAIN=example.dockerdomainresolver
```

`Caddyfile`

```
# Configuration file for Caddy used by Docker.
# https://caddyserver.com

{
  local_certs
}

{$DOMAIN} {
  respond "Hello World!"
}

www.{$DOMAIN} {
    redir https://{$DOMAIN}/
}
```

`docker-compose.yml`

```yml
services:
  domain-resolver:
    container_name: domain-resolver
    image: domjtalbot/domain-resolver
    environment:
      - DOMAIN=$DOCKER_DOMAIN
    ports:
      - "127.0.0.1:53:53/udp"
    volumes:
      - /etc/resolver:/etc/resolver:ro
    restart: always

  caddy:
    container_name: caddy
    image: caddy/caddy:alpine
    environment:
      - DOMAIN=$DOCKER_DOMAIN
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config

volumes:
  caddy_config:
  caddy_data:
```

### Run locally

To run the example locally use:

```bash
./create-host-resolver.sh --domain example.dockerdomainresolver && docker-compose up -d
```
