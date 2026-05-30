# Ignite Solutions - Complete Setup Guide

## ✅ Completed Deployments

### Infrastructure
- ✅ **Kubernetes Cluster (EKS)** - Running
- ✅ **Backend API** - Deployed via Helm & ArgoCD
- ✅ **RDS MySQL** - Dev and Prod databases ready
- ✅ **Frontend** - Built and deployed to S3 with CloudFront
- ✅ **ArgoCD** - Installed and configured

### Environments
- ✅ **Development (default namespace)** - Auto-synced via ArgoCD
- ✅ **Production (prod namespace)** - Ready for manual sync
- ✅ **Database Migrations** - Dev & Prod schemas created

### CI/CD Pipelines
- ✅ GitHub Actions workflows created:
  - `build-backend.yaml` - Build backend Docker image → ECR
  - `build-frontend.yaml` - Build React → S3 + CloudFront
  - `deploy-argocd.yaml` - Deploy via ArgoCD
  - `terraform.yaml` - Validate & apply infrastructure
  - `integration-tests.yaml` - Health checks & integration tests

---

## 🔧 Required GitHub Actions Secrets

Add these secrets to your GitHub repository: **Settings → Secrets and variables → Actions**

### AWS Credentials
```
AWS_ACCESS_KEY_ID          = <your-aws-access-key>
AWS_SECRET_ACCESS_KEY      = <your-aws-secret-key>
```

### S3 & CloudFront (Frontend)
```
S3_BUCKET_NAME             = <your-s3-bucket-name>
CLOUDFRONT_DISTRIBUTION_ID = <your-cloudfront-distribution-id>
```

### Database
```
DB_PASSWORD                = StrongPassword123!
```

### ArgoCD (Optional - for automated ArgoCD login in workflows)
```
ARGOCD_PASSWORD            = <argocd-admin-password>
ARGOCD_SERVER              = <argocd-server-url>
```

---

## 📋 Deployment Status

### Git Branching Strategy
```
main branch (production)
  ├─ Triggers: prod-pipeline.yaml
  ├─ Builds: backend image (prod-*), frontend (prod build)
  ├─ Deploys to: prod namespace via ArgoCD
  └─ Runs: prod migrations
  
dev branch (development)
  ├─ Triggers: dev-pipeline.yaml
  ├─ Builds: backend image (dev-*), frontend (dev build)
  ├─ Deploys to: default namespace via ArgoCD
  └─ Runs: dev migrations
```

### GitHub Actions Workflows

**1. dev-pipeline.yaml** (Triggers on dev branch push)
- ✅ Builds backend → ECR (dev-*)
- ✅ Builds frontend → S3 dev folder
- ✅ Deploys to default namespace via ArgoCD
- ✅ Runs dev migrations (if migrations/ changed)
- ✅ Runs integration tests

**2. prod-pipeline.yaml** (Triggers on main branch push)
- ✅ Builds backend → ECR (prod-*)
- ✅ Builds frontend → S3 prod folder
- ✅ Deploys to prod namespace via ArgoCD
- ✅ Runs prod migrations (if migrations/ changed)
- ✅ Runs integration tests

**3. database-migration.yaml** (Triggers on migrations/ changes)
- ✅ Validates SQL syntax
- ✅ Dev: Always runs on dev/main branch changes
- ✅ Prod: Runs only on main branch changes
- ✅ Manual trigger: workflow_dispatch with environment selection
- ✅ Verifies database connectivity after migration

### Development (Auto-sync)
```
$ kubectl get app -n argocd backend-api-dev
NAME              SYNC STATUS   HEALTH STATUS
backend-api-dev   Synced        Healthy
```

### Production (Manual-sync)
```
$ kubectl get app -n argocd backend-api-prod
NAME               SYNC STATUS   HEALTH STATUS
backend-api-prod   OutOfSync     Missing
```
To sync prod: `kubectl patch app backend-api-prod -n argocd -p '{"metadata":{"annotations":{"argocd.argoproj.io/sync":"sync"}}}'`

### Database Migrations
```
$ kubectl get job -n dev mysql-migration
$ kubectl get job -n prod mysql-migration
Status: Complete ✅
```

---

## 🚀 Next: Configure & Run CI/CD

1. **Add GitHub Secrets** (see section above)
2. **Push to main branch**:
   ```bash
   git push origin main
   ```
3. **Workflows will trigger automatically:**
   - Backend builds on changes to `backend-services/**`
   - Frontend builds on changes to `frontend-services/**`
   - ArgoCD sync runs on all pushes to main
   - Terraform validates on changes to `terraform/**`
   - Integration tests run on schedule (2 AM UTC daily)

---

## 📊 Workflow Details

### Build Backend (`build-backend.yaml`)
- Trigger: Push/PR to `backend-services/**` in main
- Actions:
  1. Build Docker image
  2. Push to ECR
  3. Update Helm values.yaml with new tag
  4. Commit & push back to repo
  5. ArgoCD automatically syncs new version

### Build Frontend (`build-frontend.yaml`)
- Trigger: Push/PR to `frontend-services/**` in main
- Actions:
  1. Install dependencies
  2. Run tests
  3. Build React app
  4. Sync to S3
  5. Invalidate CloudFront cache

### Deploy via ArgoCD (`deploy-argocd.yaml`)
- Trigger: Push to main OR manual workflow_dispatch
- Actions:
  1. Sync `backend-api-dev` (auto-sync)
  2. Wait for deployment ready
  3. Run dev migrations
  4. Create prod namespace
  5. Run prod migrations

### Terraform (`terraform.yaml`)
- Trigger: Push/PR to `terraform/**` OR manual
- Actions:
  1. Validate Terraform files
  2. Plan changes (all envs)
  3. Apply to dev (auto on main)

### Integration Tests (`integration-tests.yaml`)
- Trigger: On schedule (daily 2 AM UTC) + push
- Actions:
  1. Check backend health `/health`
  2. Verify database connectivity
  3. Test S3 + CloudFront availability

---

## 🔍 Accessing Services

### Backend API (Dev)
```bash
kubectl port-forward -n default svc/backend-api 5000:5000
curl http://localhost:5000/health
```

### Backend API (Prod) - After sync
```bash
kubectl port-forward -n prod svc/backend-api 5000:5000
curl http://localhost:5000/health
```

### ArgoCD UI
```bash
kubectl port-forward -n argocd svc/argocd-server 8080:443
# Access: https://localhost:8080
# Default admin password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Frontend
```
https://<your-cloudfront-domain>/web-ui/
```

### Database
```bash
kubectl run -it --rm mysql-cli --image=mysql:8 --restart=Never -- \
mysql -h platform-mysql.cvi2swcoup2y.ap-south-1.rds.amazonaws.com \
-u admin -p'StrongPassword123!' \
-e "USE platform; SELECT * FROM users;"
```

---

## � Complete CI/CD Automation Flow

### Developer Workflow

**For Development Changes (dev branch):**
```bash
git checkout dev
# Make changes to backend, frontend, or database
git commit -am "Add feature X"
git push origin dev

# Automatically triggers:
# 1. dev-pipeline.yaml
#    - Builds backend image (dev-<sha>)
#    - Builds frontend and deploys to S3-dev
#    - Deploys to default namespace
#    - Runs dev migrations (if applicable)
#    - Runs health checks
```

**For Production Release (main branch):**
```bash
git checkout main
git merge dev  # Merge from dev after testing
git push origin main

# Automatically triggers:
# 1. prod-pipeline.yaml
#    - Builds backend image (prod-<sha>)
#    - Builds frontend and deploys to S3-prod
#    - Deploys to prod namespace
#    - Runs prod migrations (if applicable)
#    - Runs health checks
# 2. database-migration.yaml (if migrations/ changed)
#    - Validates SQL
#    - Runs prod migrations
#    - Verifies database
```

**For Database-Only Changes:**
```bash
# On any branch with migrations/ changes
git add migrations/
git commit -m "Add new migration"
git push

# database-migration.yaml triggers automatically:
# - Dev: Always runs migrations/dev/*
# - Prod: Only if pushing to main branch
```

### Automated Deployment Pipeline

---

## ⚠️ Important Notes

1. **Prod is Manual Sync** - You must manually sync prod applications
2. **Secrets are Sensitive** - Never commit credentials to git
3. **RDS Must Allow Traffic** - Ensure security groups allow EKS cluster access
4. **ArgoCD Password** - Change the default admin password after first login
5. **S3 Bucket** - Must exist and frontend build/ folder uploaded at least once

---

## 🆘 Troubleshooting

### Pod won't start
```bash
kubectl logs -n default deployment/backend-api-dev
kubectl describe pod <pod-name> -n default
```

### ArgoCD app not syncing
```bash
argocd app sync backend-api-dev --grpc-web
kubectl get app -n argocd backend-api-dev -o yaml
```

### Database migration fails
```bash
kubectl logs -n dev job/mysql-migration
kubectl logs -n prod job/mysql-migration
```

### Workflow not triggering
- Check `.github/workflows/*.yaml` files exist
- Verify GitHub Actions enabled in repo settings
- Check workflow syntax: `git push` triggers workflows

---

## 📞 Support

For issues or questions:
1. Check workflow logs in GitHub → Actions
2. Check pod logs: `kubectl logs <pod>`
3. Check ArgoCD status: `kubectl get app -n argocd`
4. Review this documentation

Enjoy your fully automated deployment pipeline! 🎉
