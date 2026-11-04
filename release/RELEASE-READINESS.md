# OrderFlow v2.3.0 — Production Release Readiness Pack

**Document Version:** 1.0.0  
**Target Release Date:** 2026-11-05  
**Release Engineer:** Alex Mercer  
**Target Environment:** Production (`orderflow-prod`)  
**Repository Branch:** `investigation/release-readiness`  

---

## 1. Release Version Information
- **Application Name:** OrderFlow
- **Release Version:** `v2.3.0` (Semantic Versioning: `2.3.0`)
- **Git Commit Hash:** `9b4f2e18d`
- **Container Artifact:** `ghcr.io/kalviumcommunity/orderflow:v2.3.0`
- **Digest:** `sha256:4a8bc93e62058b2914db254e28c61e4f45b73d2a71340156d98f7e2c91b7d34a`
- **Release Type:** Minor Feature & Stability Release (Non-breaking)

---

## 2. Deployment Strategy
- **Pattern:** Rolling Update (`RollingUpdate`)
- **Zero-Downtime Parameters:**
  - `maxSurge`: 25% (allows temporary spin-up of new version pods before terminating old pods)
  - `maxUnavailable`: 0 (guarantees 100% capacity maintained throughout deployment)
- **Traffic Routing:**
  - Kubernetes Service / Ingress Controller directing external HTTPS requests to healthy pods only.
  - Active Readiness Probes ensure pods receive traffic only after passing `/health` checks.

---

## 3. Rollback Strategy
- **Rollback Target Version:** `v2.2.9` (Previous stable verified release)
- **Target RTO (Recovery Time Objective):** < 2 minutes
- **Target RPO (Recovery Point Objective):** 0 (zero transactional data loss)
- **Automated Rollback Triggers:**
  1. HTTP 5xx error rate exceeds 1% over a 3-minute sliding window.
  2. Pod restart count exceeds 2 within 5 minutes (CrashLoopBackOff detection).
  3. Health probe failure on endpoint `/health` for > 30 consecutive seconds.
- **Rollback Execution Command:**
  ```bash
  ./scripts/rollback.sh v2.2.9
  # Underlying Kubernetes action:
  kubectl rollout undo deployment/orderflow-app -n orderflow-prod
  ```

---

## 4. Deployment Infrastructure Decision
- **Architecture Choice:** Managed Kubernetes (Amazon EKS) / Container Orchestration
- **Rejection of Standalone EC2 (t2.micro):**
  - Standalone `t2.micro` instance previously configured in Terraform represented a Single Point of Failure (SPOF), offered no auto-healing, lacked autoscaling, and provided insufficient memory/CPU buffers for production load spikes.
- **Production Standard:**
  - 3 Multi-AZ replicas distributed across availability zones.
  - Resource requests: CPU 250m / Memory 256Mi; Limits: CPU 500m / Memory 512Mi.
  - Secret decoupling via Kubernetes `SecretStore CSI` and GitHub Actions encrypted environment secrets.

---

## 5. Production Approval Checklist

| Verification Gate | Responsible Stakeholder | Status | Date Signed | Verification Evidence |
| :--- | :--- | :---: | :---: | :--- |
| **Pipeline Stage Reordering** | Sarah Jenkins (Eng Mgr) | Approved | 2026-11-05 | Validation strictly gates production deployment |
| **DevSecOps Audit** | David Chen (Security Lead) | Approved | 2026-11-05 | Zero hardcoded plaintext credentials in git history |
| **Automated Test Suite** | Elena Rodriguez (QA Lead) | Approved | 2026-11-05 | All unit tests passed, health check responds 200 OK |
| **HA Infrastructure Review** | Alex Mercer (Release Eng) | Approved | 2026-11-05 | 3-replica K8s RollingUpdate verified with probes |
| **Rollback Runbook Drill** | Alex Mercer (Release Eng) | Approved | 2026-11-05 | Dry-run of `rollback.sh` executed under 60 seconds |

---

## 6. Deployment Validation Summary
- **Unit & Regression Testing:** Passed (`npm test --prefix app`)
- **Metadata Consistency Check:** Verified (`release.json` matches `package.json` v2.3.0)
- **Secret Management Compliance:** Clean (All credentials sourced via `${{ secrets.* }}` and `secretKeyRef`)
- **Health Check Assertions:** Verified (`GET /health` returns HTTP 200 with `{ status: "ok", version: "2.3.0" }`)
- **Final Verdict:** **READY FOR PRODUCTION RELEASE**
