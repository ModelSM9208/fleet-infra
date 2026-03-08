# Automated Image Sync for Local Registry

This setup automatically syncs images from public registries (Docker Hub, etc.) to your local registry every night at 3 AM.

## 📁 Files Created

- `image-sync-configmap.yaml` - Contains the list of images to sync and the sync script
- `image-sync-cronjob.yaml` - Kubernetes CronJob that runs the sync daily
- `kustomization.yaml` - Updated to include the new resources

## 🚀 Deployment

1. **Copy the new files to your manifest directory:**
   ```bash
   # Place these files alongside your existing registry.yaml and namespace.yaml
   cp image-sync-configmap.yaml /path/to/your/manifests/
   cp image-sync-cronjob.yaml /path/to/your/manifests/
   cp kustomization.yaml /path/to/your/manifests/  # This replaces your existing one
   ```

2. **Apply with kubectl:**
   ```bash
   kubectl apply -k /path/to/your/manifests/
   ```

   Or if using Flux, commit the files and let Flux sync them.

## ✏️ Adding/Removing Images

Edit the ConfigMap to add or remove images from the sync list:

```bash
kubectl edit configmap image-sync-config -n registry
```

Find the `images.txt` section and add your images. Two formats are supported:

**Simple format** (same path in both registries):
```
nginx:latest
postgres:15
```

**Custom mapping** (different paths):
```
docker.io/library/nginx:latest=nginx:latest
quay.io/prometheus/prometheus:latest=monitoring/prometheus:latest
```

After editing, the changes will take effect on the next scheduled run (3 AM).

## 🧪 Testing Manually

Don't want to wait until 3 AM? You can trigger the sync manually:

```bash
# Create a one-time job from the CronJob
kubectl create job --from=cronjob/image-sync manual-sync-1 -n registry

# Watch the job
kubectl get jobs -n registry -w

# Check the logs
kubectl logs -n registry -l job-name=manual-sync-1
```

## 📊 Monitoring

**Check when the last sync ran:**
```bash
kubectl get cronjobs -n registry
```

**View sync history:**
```bash
kubectl get jobs -n registry
```

**Check logs from the last run:**
```bash
# Find the most recent job
kubectl get jobs -n registry --sort-by=.metadata.creationTimestamp

# View its logs
kubectl logs -n registry job/image-sync-<timestamp>
```

## 🔧 Configuration

### Change the Schedule

Edit the CronJob to run at a different time:

```bash
kubectl edit cronjob image-sync -n registry
```

Change the `schedule` field. Examples:
- `0 3 * * *` - 3 AM daily (default)
- `0 2 * * *` - 2 AM daily
- `0 */6 * * *` - Every 6 hours
- `0 3 * * 0` - 3 AM on Sundays only

### Add More Images

Common images you might want to add to `images.txt`:

```
# Databases
mysql:8
mariadb:latest
mongodb:7

# Caching
memcached:alpine
valkey:latest

# Web Servers
httpd:alpine
caddy:latest

# Tools
busybox:latest
curl:latest
```

## 🔍 Troubleshooting

**Images not showing up in registry?**
1. Check the job logs: `kubectl logs -n registry -l app=image-sync`
2. Verify registry is accessible: `kubectl get svc -n registry`
3. Check if the job ran: `kubectl get jobs -n registry`

**Sync fails with TLS errors?**
The script uses `--dest-tls-verify=false` because your local registry doesn't have proper TLS. This is fine for local development.

**Want to sync images from private registries?**
You'll need to add authentication. Create a secret with credentials and mount it in the CronJob.

## 📝 How It Works

1. **CronJob** runs daily at 3 AM
2. **Skopeo** reads the image list from the ConfigMap
3. For each image:
   - Copies directly from source registry to your local registry
   - No intermediate storage needed (efficient!)
4. **Logs** show success/failure for each image
5. **Job history** is kept for debugging

## 🎯 Next Steps

1. Deploy the manifests
2. Edit the ConfigMap to add your frequently-used images
3. Run a manual sync to test
4. Check your registry to see the images: `curl http://registry.registry.svc.cluster.local:5000/v2/_catalog`

Now you'll have fresh images waiting every morning without slow pulls during testing! 🚀
