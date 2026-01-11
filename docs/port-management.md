# Port Management in Local Development

When running multiple projects, services, or AI agents in parallel, port conflicts become inevitable. This doc covers practical solutions.

## The Problem

```
Error: listen EADDRINUSE: address already in use :::3000
```

Common scenarios:
- Multiple worktrees/branches with dev servers
- Docker Compose services (qdrant, postgres, redis) across projects
- AI agents spinning up servers autonomously
- Forgetting what's running where

## Quick Fixes

### Find What's Using a Port

```bash
# What's on port 3000?
lsof -i :3000

# Kill it
kill -9 $(lsof -t -i :3000)

# List all listening ports
lsof -iTCP -sTCP:LISTEN -n -P
```

### Docker-Specific

```bash
# See all exposed ports
docker ps --format "table {{.Names}}\t{{.Ports}}"

# Stop all containers
docker stop $(docker ps -q)
```

---

## Solution 1: port-selector (Zero Config)

A CLI tool that assigns and remembers ports per directory.

### Install

```bash
brew tap dapi/tap && brew install port-selector
# or
curl -sSL https://raw.githubusercontent.com/dapi/port-selector/main/install.sh | sh
```

### Usage

```bash
# Get a port (sticky per directory)
cd ~/projects/project-a
port-selector  # → 3000

cd ~/projects/project-b
port-selector  # → 3001

cd ~/projects/project-a
port-selector  # → 3000 (same as before!)

# With dev server
npm run dev -- --port $(port-selector)

# See all assignments
port-selector --list
```

### With Docker Compose

```yaml
# docker-compose.yml
services:
  qdrant:
    image: qdrant/qdrant
    ports:
      - "${QDRANT_PORT:-6333}:6333"
      - "${QDRANT_GRPC_PORT:-6334}:6334"
```

```bash
# Start with auto-assigned port
QDRANT_PORT=$(port-selector) docker-compose up

# Or add to a wrapper script
```

### Pros/Cons

| Pros | Cons |
|------|------|
| Zero config | Another tool to install |
| Ports "stick" to directories | Requires remembering to use it |
| Works with any dev server | Docker Compose needs env vars |

**Links:** [GitHub](https://github.com/dapi/port-selector)

---

## Solution 2: Unix Sockets + Reverse Proxy

Instead of TCP ports, services listen on Unix sockets. A reverse proxy (nginx/caddy) routes by hostname.

### How It Works

```
Browser → http://qdrant.local:80 → nginx → /tmp/qdrant.sock → qdrant
Browser → http://api.local:80    → nginx → /tmp/api.sock    → your app
```

No port numbers to manage. Each service gets a human-readable hostname.

### Setup (nginx)

**1. Configure your service to use a socket:**

```ini
# Example: forgejo config
[server]
PROTOCOL = http+unix
HTTP_ADDR = /tmp/forgejo.sock
```

**2. Add nginx upstream:**

```nginx
# /etc/nginx/sites-enabled/forgejo.conf
upstream forgejo {
    server unix:/tmp/forgejo.sock;
}

server {
    listen 80;
    server_name git.local forgejo.local;

    location / {
        proxy_pass http://forgejo;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

**3. Add to /etc/hosts or local DNS:**

```
127.0.0.1 git.local forgejo.local
```

### For Docker (Socket Binding)

```yaml
# docker-compose.yml
services:
  qdrant:
    image: qdrant/qdrant
    volumes:
      - /tmp/qdrant.sock:/qdrant/qdrant.sock
    # No ports exposed!
```

Then nginx proxies to the socket.

### macOS Considerations

- No systemd socket activation (Linux-only feature)
- Use Homebrew nginx: `brew install nginx`
- Config at: `/opt/homebrew/etc/nginx/`
- Logs at: `/opt/homebrew/var/log/nginx/`

### Pros/Cons

| Pros | Cons |
|------|------|
| No port conflicts ever | More initial setup |
| Human-readable URLs | Requires nginx/caddy running |
| Works across all services | Socket permissions can be tricky |
| Professional setup | Overkill for simple projects |

**Links:** [nginx docs](https://nginx.org/en/docs/http/ngx_http_upstream_module.html#server)

---

## Solution 3: Docker Networks (No Host Ports)

If services only need to talk to each other, don't expose ports at all.

```yaml
# docker-compose.yml
services:
  app:
    build: .
    depends_on:
      - qdrant
    environment:
      - QDRANT_URL=http://qdrant:6333  # Container name as hostname
    networks:
      - internal

  qdrant:
    image: qdrant/qdrant
    # No "ports:" section - not exposed to host
    networks:
      - internal

networks:
  internal:
```

Services communicate via container names within the Docker network.

**When you need host access** (for debugging):

```bash
# Temporarily forward port
docker exec -it qdrant-container sh -c "nc -l -p 6333"
# or
docker run --rm -it --network=container:qdrant nicolaka/netshoot
```

---

## Solution 4: Shared Services

Instead of per-project instances, run one shared service.

### Shared Qdrant Example

```bash
# Run once, globally
docker run -d \
  --name qdrant-shared \
  -p 6333:6333 \
  -v ~/docker-data/qdrant:/qdrant/storage \
  --restart unless-stopped \
  qdrant/qdrant
```

Use different collections per project:

```python
# project-a
client.create_collection("project_a_embeddings", ...)

# project-b
client.create_collection("project_b_embeddings", ...)
```

---

## Quick Reference

| Approach | Best For | Complexity |
|----------|----------|------------|
| port-selector | Dev servers, quick parallel work | Low |
| Unix sockets | Persistent services, team setups | Medium |
| Docker networks | Microservices that talk to each other | Low |
| Shared services | Databases, vector stores | Low |

## Troubleshooting

### "Address already in use"

```bash
# Find and kill
lsof -i :PORT
kill -9 PID
```

### Docker port still bound after stop

```bash
# Force remove
docker rm -f container_name

# If still stuck, restart Docker
killall Docker && open /Applications/Docker.app
```

### nginx "permission denied" on socket

```bash
# Check socket permissions
ls -la /tmp/*.sock

# Fix ownership (if needed)
chmod 666 /tmp/your.sock
```

---

## Links

- [port-selector](https://github.com/dapi/port-selector) - CLI for automatic port assignment
- [nginx upstream docs](https://nginx.org/en/docs/http/ngx_http_upstream_module.html)
- [Docker networking](https://docs.docker.com/network/)
- [Caddy reverse proxy](https://caddyserver.com/docs/quick-starts/reverse-proxy) - simpler than nginx
