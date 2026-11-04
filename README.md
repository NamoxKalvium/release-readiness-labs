# OrderFlow — Production Release Readiness

This repository contains the Release Readiness Investigation, Security Hardening, and Deployment Pipeline configuration for **OrderFlow v2.3.0**.

## Current Release: `v2.3.0`
- **Release Status:** Production Ready (Approved)
- **Deployment Branch:** `investigation/release-readiness`
- **Target Platform:** Kubernetes (Amazon EKS)
- **Deployment Strategy:** Zero-Downtime RollingUpdate (3 Replicas)

---

## Release Readiness Summary

All production-readiness defects identified during initial investigation have been resolved:

1. **Pipeline Sequencing Fixed:** Validation stages now strictly precede production deployment.
2. **Secret Hygiene Enforced:** All hardcoded credentials removed and replaced with encrypted secrets and Kubernetes `secretKeyRef`.
3. **Traceability Established:** Semantic versioning pinned across `release.json`, `package.json`, Docker tag `orderflow:v2.3.0`, and deployment manifests.
4. **Resilient Infrastructure Selected:** Abandoned single `t2.micro` EC2 in favor of multi-AZ Kubernetes container orchestration.
5. **Rollback Runbook Established:** Automated rollback mechanism (`scripts/rollback.sh`) tested with target RTO < 2 minutes.
6. **Stakeholder Approvals Documented:** Fully signed off in `release/approvals.yml` and `release/RELEASE-READINESS.md`.

---

## Repository Structure
```
├── .github/
│   └── workflows/
│       └── release.yml          # Fixed CI/CD pipeline (Validate -> Deploy)
├── app/
│   ├── server.js                # Express API with /health probe
│   └── package.json             # Pinned to v2.3.0
├── deployment/
│   ├── kubernetes/
│   │   ├── deployment.yaml      # Multi-replica HA deployment with SecretStore refs
│   │   └── service.yaml         # LoadBalancer routing
│   └── terraform/
│       ├── main.tf              # Production VPC & Cluster infrastructure
│       └── variables.tf         # Sensitive variable declarations (no defaults)
├── release/
│   ├── approvals.yml            # Stakeholder approvals
│   ├── deployment-config.yml    # Hardened release configuration
│   ├── release.json             # Immutable release metadata
│   ├── release-summary.yml      # Release summary report
│   ├── rollback.yml             # Automated rollback specifications
│   └── RELEASE-READINESS.md     # Complete Release Readiness Pack
├── scripts/
│   ├── deploy.sh                # Parameterized zero-downtime deployment script
│   └── rollback.sh              # Automated rollback recovery script
├── Dockerfile                   # Node 18 multi-stage production container
├── docker-compose.yml           # Local validation harness
└── README.md
```

## Running Verification Locally
```bash
# Test validation
npm test --prefix app

# Run local deployment verification
chmod +x scripts/deploy.sh
./scripts/deploy.sh v2.3.0
```
