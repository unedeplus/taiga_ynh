# Taiga Frontend Build Workarounds

## Problem

Taiga's frontend build requires ~8GB RAM during `npm install` due to 1000+ dependencies including git-based packages. YunoHost servers with less RAM will experience memory exhaustion (SIGKILL) during installation.

## Symptoms

- Installation fails after 15-25 minutes
- Error: `npm ERR! signal SIGKILL` 
- Error: `git dep preparation failed`
- YunoHost log shows: `Unable to install taiga`

## Solutions

### Option 1: Build on External Machine (Recommended)

If you have access to another machine with 8GB+ RAM:

1. **On the build machine:**
   ```bash
   bash build-frontend-external.sh
   ```
   This will:
   - Clone Taiga frontend
   - Install dependencies with sufficient memory
   - Build the production assets
   - Package everything into `taiga-front-6.7.0-dist.tar.gz`

2. **Upload to YunoHost server:**
   ```bash
   scp taiga-front-6.7.0-dist.tar.gz admin@192.168.1.170:/tmp/taiga-front-prebuilt.tar.gz
   ```
   Note: Must rename to `taiga-front-prebuilt.tar.gz`

3. **Install Taiga:**
   ```bash
   ssh admin@192.168.1.170
   sudo yunohost app install https://github.com/unedeplus/taiga_ynh
   ```
   The install script will automatically detect and use the pre-built package.

### Option 2: Extract from Docker Image

If you have Docker available on any machine:

1. **Extract pre-built assets:**
   ```bash
   bash extract-frontend-docker.sh
   ```
   This pulls the official `taigaio/taiga-front:6.7.0` Docker image and extracts the already-built frontend.

2. **Upload and install:**
   ```bash
   scp taiga-front-6.7.0-docker-dist.tar.gz admin@192.168.1.170:/tmp/taiga-front-prebuilt.tar.gz
   ssh admin@192.168.1.170
   sudo yunohost app install https://github.com/unedeplus/taiga_ynh
   ```

### Option 3: Temporarily Upgrade Server RAM

For VPS users:

1. Upgrade your server to 8GB RAM temporarily
2. Install Taiga (build will succeed)
3. Downgrade RAM after installation complete

**Cost:** Typically €5-10 one-time upgrade fee

**Note:** Once installed, Taiga runs fine on 2GB RAM. The 8GB requirement is only for the build process.

### Option 4: Increase Swap Space (May Not Work)

If you're determined to build on the server:

1. **Add 4GB swap:**
   ```bash
   ssh admin@192.168.1.170
   sudo fallocate -l 4G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   ```

2. **Try installation:**
   ```bash
   sudo yunohost app install https://github.com/unedeplus/taiga_ynh
   ```

3. **Remove swap after:**
   ```bash
   sudo swapoff /swapfile
   sudo rm /swapfile
   ```

**Warning:** This may still fail. Swap is much slower than RAM, and the Linux kernel may still trigger OOM killer.

## Technical Details

### Why Does This Happen?

- Taiga v6.7.0 frontend has 1000+ npm dependencies
- Many dependencies are git-based packages
- npm spawns multiple git subprocesses during installation
- Each subprocess consumes memory
- Peak memory usage during dependency resolution: ~6-8GB

### Memory Breakdown

| Phase | Memory Required |
|-------|----------------|
| npm metadata fetch | ~1GB |
| Dependency resolution | ~3GB |
| Git clones (parallel) | ~4GB |
| node-sass compilation | ~2GB |
| **Total Peak** | **~8GB** |

### Why Pre-built Works

The pre-built approach:
- Skips `npm install` entirely
- Uses already-compiled dependencies
- Only extracts files (minimal memory)
- Installation completes in seconds

## Verification

After installation, verify frontend is working:

```bash
ssh admin@192.168.1.170
ls -lh /var/www/taiga/taiga-front/dist/
```

Should show compiled frontend assets (HTML, JS, CSS).

## Future Versions

Taiga v6.9.0 (latest) likely has MORE dependencies than v6.7.0, so memory requirements may be higher. Always use pre-built approach for servers with <8GB RAM.

## Support

If you encounter issues:
1. Check `/var/log/yunohost/app/taiga/installation*.log`
2. Look for memory-related errors (SIGKILL, heap exhaustion)
3. Verify you renamed the package to `/tmp/taiga-front-prebuilt.tar.gz`
4. Ensure package was uploaded before running installation
