# 🚀 Ignite Solutions - Complete CI/CD Automation Guide

## ✅ Status: FULLY AUTOMATED

Your infrastructure now has **complete end-to-end automation** with separate pipelines for development and production environments.

---

## 🔄 Automated Pipelines Summary

### **1. Development Pipeline** (`dev-pipeline.yaml`)
**Triggers:** Push to `dev` branch

**What it does:**
```
Developer pushes to dev
        ↓
Backend changed?
├─ Build Docker image (dev-<commit-sha>)
├─ Push to ECR (backend-api-dev)
└─ Update Helm values.yaml with new tag
        ↓
Frontend changed?
├─ Install npm dependencies
├─ Run tests
├─ Build React app with dev API URL
├─ Upload to S3/web-ui-dev/
└─ Invalidate CloudFront cache
        ↓
Deploy to DEV environment (default namespace)
├─ Restart backend-api-dev deployment
├─ Wait for rollout status
└─ Verify pod status
        ↓
Database changed?
├─ Apply secret (DB credentials)
├─ Apply configmap (SQL schema)
└─ Run migration job → database created ✓
        ↓
Run tests
├─ Health check: /health endpoint
├─ Database connectivity test
└─ Report results
```

### **2. Production Pipeline** (`prod-pipeline.yaml`)
**Triggers:** Push to `main` branch

**What it does:**
```
Developer pushes to main
        ↓
Backend changed?
├─ Build Docker image (prod-<commit-sha>)
├─ Push to ECR (backend-api-prod)
└─ Update Helm values.yaml with new tag
        ↓
Frontend changed?
├─ Install npm dependencies
├─ Run tests
├─ Build React app with prod API URL
├─ Upload to S3/web-ui/ (production folder)
└─ Invalidate CloudFront cache
        ↓
Deploy to PROD environment (prod namespace)
├─ Create prod namespace if not exists
├─ Restart backend-api-prod deployment
├─ Wait for rollout status
└─ Verify pod status
        ↓
Database changed?
├─ Apply secret (DB credentials)
├─ Apply configmap (SQL schema)
└─ Run migration job → database updated ✓
        ↓
Run tests
├─ Health check: /health endpoint
├─ Database connectivity test
└─ Report results
```

### **3. Database Migration Pipeline** (`database-migration.yaml`)
**Triggers:** 
- Push to `dev` or `main` with changes in `migrations/`
- Manual trigger (workflow_dispatch) with environment selection

**What it does:**
```
Database migration files changed
        ↓
Validate SQL
├─ Check for CREATE TABLE statements
├─ Check for CREATE DATABASE statements
└─ Validate syntax
        ↓
Run Dev Migrations
├─ Create dev namespace
├─ Apply secret (RDS credentials)
├─ Apply configmap (SQL files)
├─ Run migration job
└─ Verify database created
        ↓
Run Prod Migrations (only on main branch or manual trigger)
├─ Create prod namespace
├─ Apply secret (RDS credentials)
├─ Apply configmap (SQL files)
├─ Run migration job
└─ Verify database updated
        ↓
Report Migration Status
└─ Success/Failure for each environment
```

---

## 📦 Secrets Required in GitHub

Add these in **Settings → Secrets and variables → Actions**:

```
AWS_ACCESS_KEY_ID              # Required for all builds/deployments
AWS_SECRET_ACCESS_KEY          # Required for all builds/deployments
S3_BUCKET_NAME                 # S3 bucket for frontend
CLOUDFRONT_DISTRIBUTION_ID     # CloudFront dist ID (prod)
CLOUDFRONT_DISTRIBUTION_ID_DEV # CloudFront dist ID (dev)
DB_PASSWORD                    # RDS password
```

---

## 🔄 Complete Workflow Example

### Scenario 1: Backend Feature Development

```bash
# 1. Developer creates feature branch from dev
git checkout dev
git checkout -b feature/user-api-v2
git add backend-services/
git commit -m "feat: add user API v2 endpoint"

# 2. Push to dev branch
git push origin feature/user-api-v2

# 3. Create PR to merge into dev
# → GitHub Actions automatically:
#    - Builds Docker image (dev-<sha>)
#    - Pushes to ECR
#    - Deploys to dev namespace
#    - Runs health checks
#    ✓ Ready for testing

# 4. After testing, merge PR into dev
git checkout dev
git merge feature/user-api-v2
git push origin dev

# 5. Workflow runs again in dev environment
# ✓ Dev is now running v2 API

# 6. After approval, merge dev into main for production
git checkout main
git merge dev
git push origin main

# 7. Workflow runs in prod environment
# ✓ Production updated to v2 API
```

### Scenario 2: Database Schema Update

```bash
# 1. Update migration file
nano migrations/dev/create_users.sql
# Add new column: ALTER TABLE users ADD COLUMN phone VARCHAR(20);

# 2. Commit and push to dev
git add migrations/dev/
git commit -m "feat: add phone column to users table"
git push origin dev

# 3. database-migration.yaml triggers:
#    - Validates SQL
#    - Runs dev migration
#    - Creates table/column changes
#    ✓ Dev database updated

# 4. Copy changes to prod
cp migrations/dev/create_users.sql migrations/prod/
git add migrations/prod/
git commit -m "feat: add phone column to users table (prod)"
git push origin main

# 5. database-migration.yaml triggers prod migration:
#    - Validates SQL
#    - Runs prod migration
#    - Prod database updated
#    ✓ Both environments synced
```

### Scenario 3: Frontend Redesign

```bash
# 1. Work on feature branch
git checkout dev
git checkout -b feature/new-ui-design
cd frontend-services/frontend-apps/web-ui
# Edit React components...

# 2. Push changes
git add frontend-services/
git commit -m "feat: new UI design"
git push origin feature/new-ui-design

# 3. GitHub Actions triggers dev-pipeline:
#    - npm install
#    - npm test (unit tests)
#    - npm build
#    - Upload to S3/web-ui-dev/
#    - Invalidate CloudFront cache for dev
#    ✓ Dev frontend updated, ready for review

# 4. Merge to dev after review
git checkout dev
git merge feature/new-ui-design
git push origin dev

# 5. Test in dev, then merge to main
git checkout main
git merge dev
git push origin main

# 6. GitHub Actions triggers prod-pipeline:
#    - Rebuilds with prod API URL
#    - Upload to S3/web-ui/ (prod)
#    - Invalidate CloudFront cache
#    ✓ Production frontend updated
```

---

## 🎯 Deployment Environments

### Development (dev branch)
- **Namespace:** `default`
- **Backend:** `backend-api-dev` (auto-deployed)
- **Frontend:** `s3://bucket/web-ui-dev/`
- **Database:** `mysql-migration` job in `dev` namespace
- **Auto-Sync:** Enabled (changes applied immediately)

### Production (main branch)
- **Namespace:** `prod`
- **Backend:** `backend-api-prod` (auto-deployed)
- **Frontend:** `s3://bucket/web-ui/`
- **Database:** `mysql-migration` job in `prod` namespace
- **Auto-Sync:** Enabled (changes applied immediately)

---

## 📊 Viewing Pipeline Execution

### In GitHub
1. Go to repository **Actions** tab
2. Select workflow (dev-pipeline, prod-pipeline, database-migration)
3. View real-time execution logs
4. Check for errors in each step

### In Kubernetes
```bash
# View deployment status
kubectl get deployments -n default -l app.kubernetes.io/name=backend-api
kubectl get deployments -n prod -l app.kubernetes.io/name=backend-api

# View pod status
kubectl get pods -n default
kubectl get pods -n prod

# View migration jobs
kubectl get job -n dev mysql-migration
kubectl get job -n prod mysql-migration

# View logs
kubectl logs -n default -l app.kubernetes.io/name=backend-api --tail=50
kubectl logs -n prod -l app.kubernetes.io/name=backend-api --tail=50
kubectl logs -n dev job/mysql-migration --tail=50
```

---

## 🔐 How Secrets Are Used

```
GitHub Secrets
    ↓
dev-pipeline.yaml (dev branch)
├─ AWS credentials → Build Docker image → Push to ECR (backend-api-dev)
├─ S3_BUCKET_NAME → Deploy to s3://bucket/web-ui-dev/
├─ CLOUDFRONT_DISTRIBUTION_ID_DEV → Invalidate dev CDN
└─ DB_PASSWORD → Run dev migrations
    ↓
prod-pipeline.yaml (main branch)
├─ AWS credentials → Build Docker image → Push to ECR (backend-api-prod)
├─ S3_BUCKET_NAME → Deploy to s3://bucket/web-ui/
├─ CLOUDFRONT_DISTRIBUTION_ID → Invalidate prod CDN
└─ DB_PASSWORD → Run prod migrations
    ↓
database-migration.yaml (any branch with migrations changes)
├─ AWS credentials → Connect to EKS cluster
└─ DB_PASSWORD → Connect to RDS for migration verification
```

---

## ⚡ Key Features

✅ **Automatic Backend Builds**
- Builds Docker image on code change
- Tags with environment (dev-*, prod-*)
- Automatically updates Helm values.yaml
- Deploys via ArgoCD

✅ **Automatic Frontend Deployment**
- Builds React app with environment-specific API URL
- Runs unit tests before build
- Uploads to S3 (dev or prod folder)
- Invalidates CloudFront cache

✅ **Automatic Database Migrations**
- Validates SQL syntax before running
- Separate dev and prod migration jobs
- Verifies database connectivity after migration
- Manual trigger option for ad-hoc migrations

✅ **Integration Testing**
- Health checks after deployment
- Database connectivity verification
- Pod status verification
- Comprehensive logging

✅ **Zero-Downtime Deployments**
- Kubernetes rolling updates
- Health probes ensure readiness
- ArgoCD automatic sync

---

## 🚨 Important Notes

1. **Secrets Setup Required** - Workflows won't run without GitHub secrets configured
2. **Branch Protection** - Consider protecting main branch with PR requirement
3. **Manual Approval** - Database migrations can be triggered manually via workflow_dispatch
4. **RDS Access** - Ensure EKS cluster security group allows MySQL access
5. **S3 Bucket** - Must exist and have appropriate permissions
6. **CloudFront** - Two distribution IDs needed (dev and prod)

---

## 🔍 Troubleshooting

### Workflow not triggering?
- Check GitHub Actions enabled in repo settings
- Verify branch names (dev vs main)
- Check workflow file syntax (`.github/workflows/*.yaml`)
- Verify secrets are configured

### Build fails?
- Check GitHub Actions logs
- Verify AWS credentials in secrets
- Check Docker build logs in ECR
- Verify image registry access

### Deployment fails?
- Check EKS cluster health: `kubectl cluster-info`
- Verify ArgoCD sync: `kubectl get app -n argocd`
- Check pod logs: `kubectl logs -n <namespace> <pod>`
- Verify security groups allow traffic

### Migration fails?
- Check RDS security group allows EKS access
- Verify database credentials in secret
- Check SQL syntax in migrations/
- Review migration job logs: `kubectl logs -n <namespace> job/mysql-migration`

---

## 📈 Next Steps

1. **Create dev branch:**
   ```bash
   git checkout -b dev
   git push -u origin dev
   ```

2. **Configure GitHub Secrets** (if not done already)

3. **Test the pipeline:**
   - Make a small change in `dev` branch
   - Push and watch Actions tab
   - Verify deployment in dev environment

4. **Set up branch protection:**
   - Settings → Branches → Add rule for `main`
   - Require PR reviews before merge
   - Require status checks to pass

5. **Monitor with dashboards:**
   - GitHub Actions tab for workflow status
   - ArgoCD UI for deployment status
   - Kubernetes dashboard for pod status

---

## 📞 Support

All changes are logged in GitHub Actions. Check the **Actions** tab for:
- Real-time execution logs
- Error messages
- Performance metrics
- Build artifacts

Your fully automated CI/CD pipeline is ready! 🎉
