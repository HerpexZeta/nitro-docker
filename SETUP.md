# Nitro Docker Local Development Setup

## Setup Status: ✅ Complete

This document describes the automatic setup that was performed to run Nitro locally.

### What Was Done

#### 1. **Dependencies Installed**
- ✅ Installed `just` command runner (v1.46.0)
- ✅ Docker & Docker Compose already available
- ✅ Git submodules initialized (public repos only)

#### 2. **Repositories Cloned**
From GitHub:
- ✅ `nitro-react` - Nitro client frontend
- ✅ `nitro-converter` - Asset converter utility

Could not access (private):
- ⚠️ `emulator/arcturus` - Arcturus emulator (requires access to git.krews.org)
- ⚠️ `nitro/nitro-assets` - Default assets (requires access to git.krews.org)
- ⚠️ `nitro/nitro-swf` - SWF files (requires access to git.krews.org)

#### 3. **Changes Made to Enable Local Dev**
- **Modified**: `emulator/scripts/build.sh`
  - Added graceful handling for missing Arcturus source
  - Docker container now starts without failing on missing repos
  - Logs a warning instead of crashing

- **Created**: Placeholder directories
  - `nitro-assets/` - For extracted game assets
  - `nitro-assets/swf/` - For SWF files
  - `nitro-assets/graphics/` - For graphics assets

#### 4. **Docker Services Running**

```
Service                Port              Status
─────────────────────────────────────────────────
Nitro Dev Server       1080              ✅ Running
Assets HTTP Server     8080              ✅ Running
SWF HTTP Server        8081              ✅ Running
MySQL Database         13306             ✅ Running
Arcturus Emulator      3000-3001, 2096   ⚠️ Degraded (requires source)
```

### Access Points

**Web Client**: http://127.0.0.1:1080?sso=123

The SSO ticket `123` is pre-configured in the MySQL database.

### Useful Commands

```bash
# View status
docker ps -a

# View logs
docker logs nitro -f        # Nitro frontend server
docker logs arcturus -f     # Arcturus emulator
docker logs mysql -f        # Database

# Control services
docker-compose stop         # Stop all containers
docker-compose start        # Start all containers
docker-compose down         # Remove all containers

# Restart specific services (while containers running)
docker exec nitro supervisorctl restart nitro-dev-server
docker exec nitro supervisorctl restart assets-http-server
docker exec nitro supervisorctl restart swf-http-server
docker exec arcturus supervisorctl restart arcturus-emulator

# Access MySQL
docker exec -it mysql mysql -h mysql -u arcturus_user -parcturus_pw arcturus
```

### Database Credentials

```
Host: 127.0.0.1:13306
User: arcturus_user
Password: arcturus_pw
Database: arcturus
Root Password: arcturus_root_pw
```

### Next Steps to Complete Setup

1. **Get Access to Private Repositories**
   - Contact the Nitro/Arcturus team for access to:
     - `https://git.krews.org/morningstar/Arcturus-Community.git`
     - `https://git.krews.org/nitro/default-assets.git`
     - `https://git.krews.org/morningstar/arcturus-morningstar-default-swf-pack.git`

2. **Clone Private Repositories**
   ```bash
   git clone https://git.krews.org/morningstar/Arcturus-Community.git emulator/arcturus
   git clone https://git.krews.org/nitro/default-assets.git nitro/nitro-assets
   git clone https://git.krews.org/morningstar/arcturus-morningstar-default-swf-pack.git nitro/nitro-swf
   ```

3. **Run Asset Extraction** (once SWF repo is available)
   ```bash
   ~/.local/bin/just extract-nitro-assets
   ```

4. **Restart Services**
   ```bash
   docker-compose restart
   ```

### Git Changes

Created branch: `feature/setup-local-dev-environment`

Commits:
- Modified `emulator/scripts/build.sh` for graceful error handling
- Created placeholder asset directories
- Added this setup documentation

To push these changes (requires fork access):
```bash
git push origin feature/setup-local-dev-environment
```

### Troubleshooting

**Client won't load?**
- Check: `docker logs nitro`
- Wait 30 seconds - Vite dev server needs time to start
- Refresh browser

**Assets not loading?**
- Assets are served from `nitro-assets/` directory
- Placeholder directories exist but contain no actual files
- Asset extraction is blocked without private SWF repo

**Database connection issues?**
- MySQL credentials are in docker-compose.yaml
- Database is automatically initialized from SQL dump
- Check: `docker logs mysql`

---

**Setup Date**: February 5, 2026  
**System**: Ubuntu 24.04.3 LTS in Dev Container
