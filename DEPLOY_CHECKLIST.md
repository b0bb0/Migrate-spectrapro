# Deploy Checklist: Spectra — Full Platform Release
**Date:** 2026-03-19 | **Project:** Spectra (Next.js Frontend + Express.js Backend)

---

## ⚠️ This Deploy Includes High-Risk Changes
- Database migrations (Prisma)
- Breaking API changes
- New dependencies (npm / Python)
- Feature flag changes

---

## 1. Pre-Deploy — Code & CI

- [ ] All PRs reviewed and approved (no open, unreviewed changes)
- [ ] CI pipeline is green (tests, lint, type-check all passing)
- [ ] `npm run lint` passes in both `platform/frontend` and `platform/backend`
- [ ] `black src/ && flake8 src/` passes for Python CLI
- [ ] `pytest tests/ -v` passes — all Python tests green
- [ ] `cd platform/backend && npm test` passes — all backend tests green
- [ ] TypeScript compiles cleanly: `cd platform/backend && npm run build`
- [ ] Next.js builds cleanly: `cd platform/frontend && npm run build`
- [ ] No `console.log` / debug output left in production paths
- [ ] `CHANGELOG.md` updated with this release's changes

---

## 2. New Dependencies

- [ ] All new npm packages audited: `npm audit` shows no critical vulnerabilities
- [ ] New Python packages added to `requirements.txt` and pinned to a version
- [ ] `pip install -r requirements.txt` tested in a clean virtualenv
- [ ] No packages with known CVEs or abandoned maintenance
- [ ] License compatibility verified for any new third-party packages

---

## 3. Database Migrations (Prisma)

> ⚠️ Drop schema before applying new migrations to avoid conflicts (see Known Gotchas in CLAUDE.md)

- [ ] Migration diff reviewed — no accidental column drops or destructive changes
- [ ] Migration tested against a staging/dev copy of the database
- [ ] Backup of production PostgreSQL taken before deploy
- [ ] `npm run prisma:migrate` tested on staging and confirmed clean
- [ ] `npm run prisma:generate` run after migration — Prisma client up to date
- [ ] Rollback SQL prepared in case migration needs to be reversed manually
- [ ] All new DB queries include `tenantId` filtering (multi-tenancy requirement)

---

## 4. Feature Flags

- [ ] New flags documented with their default state (on/off)
- [ ] Flags are off by default in production unless intentionally launching
- [ ] Flags have been tested in both enabled and disabled states
- [ ] No feature flag references left pointing to deleted/renamed flags
- [ ] Flag rollout plan confirmed (% of tenants, specific tenant IDs, etc.)

---

## 5. Breaking API Changes

- [ ] All breaking changes documented in `CHANGELOG.md`
- [ ] Any consumers of the changed endpoints identified (CLI → platform `POST /api/scans/ingest`)
- [ ] CLI scanner (`src/`) tested against the new API contract
- [ ] API version bump applied if using versioned routes
- [ ] Downstream clients (if any external integrations) notified ahead of deploy
- [ ] Backward-compatible shim or deprecation period in place if needed
- [ ] Zod validation schemas updated to match new request/response shapes

---

## 6. Auth & Multi-Tenancy

- [ ] JWT secret is set correctly in production environment variables
- [ ] All new routes go through: `Auth Check → Tenant Isolation → Role Check → Handler`
- [ ] No routes accidentally bypass tenant filtering
- [ ] ADMIN / ANALYST / VIEWER role permissions verified for new features

---

## 7. Environment & Config

- [ ] All required environment variables set in production:
  - `DATABASE_URL` (PostgreSQL 15+)
  - `JWT_SECRET`
  - Ollama URL (if configured externally)
  - Any new env vars introduced in this release
- [ ] `config/config.yaml` reviewed — Nuclei path, rate limits, timeouts appropriate for prod
- [ ] Ollama is running (`ollama serve`) if AI analysis is expected in this deploy
- [ ] Nuclei is installed and in PATH on the target host

---

## 8. Staging Verification

- [ ] Full platform deployed to staging environment
- [ ] Smoke tests run against staging:
  - [ ] Login / JWT auth flow works
  - [ ] Scan creation and ingest (`POST /api/scans/ingest`) works
  - [ ] WebSocket real-time updates work
  - [ ] Executive dashboard loads with correct metrics
  - [ ] Vulnerability deduplication behaves as expected
- [ ] No unexpected errors in staging logs (`Winston` structured logs checked)
- [ ] Prisma Studio (`npm run prisma:studio`) used to spot-check DB state after migration

---

## 9. Deploy to Production

- [ ] Deploy backend (`platform/backend`) — `npm run build` artifact pushed
- [ ] Run `npm run prisma:migrate` against production DB
- [ ] Deploy frontend (`platform/frontend`) — Next.js build pushed
- [ ] Services restarted cleanly (no stale processes)
- [ ] Monitor error rates and response latency for **15 minutes post-deploy**
- [ ] Check WebSocket connections are healthy
- [ ] Verify at least one end-to-end scan flow in production

---

## 10. Post-Deploy

- [ ] Metrics are nominal (error rate, P50/P95 latency within baseline)
- [ ] No spike in `AuditLog` errors or auth failures
- [ ] Release notes / `CHANGELOG.md` entry published or shared
- [ ] Stakeholders notified that deploy is complete
- [ ] Related tickets closed
- [ ] MEMORY.md / session context updated with deploy outcome (if applicable)

---

## 🚨 Rollback Triggers

Roll back immediately if any of the following occur within 30 minutes of deploy:

- [ ] Error rate exceeds **5%** on any core API route
- [ ] `POST /api/scans/ingest` fails for more than 2 consecutive attempts
- [ ] WebSocket connections drop and do not recover within 2 minutes
- [ ] Database migration leaves schema in inconsistent state
- [ ] JWT auth failures spike (users unable to log in)
- [ ] Any data loss or cross-tenant data leak detected

**Rollback procedure:**
1. Revert frontend and backend to previous build artifacts
2. Run rollback SQL (prepared in step 3 above) if migration needs reverting
3. Confirm services are healthy on the previous version
4. Page on-call team and open incident if rollback is triggered

---

*Generated by Claude for Spectra platform deploy — 2026-03-19*
