# QA Plan

## Test Strategy & Approach
- **Automated coverage**: Flutter unit/widget tests cover core models, services, receipt workflow, and key UI screens. CI executes `flutter analyze` and `flutter test` on every push/PR.
- **Manual smoke**: For each build, verify camera capture, OCR flow, review screen edits, achievement unlock notification, and navigation back to the dashboard.
- **Device matrix**: Test on at least one Android (API 33+) and one iOS (17+) device/emulator monthly; interim verification uses Android emulator in CI smoke.
- **Data integrity**: Spot-check SQLite contents after scans (vendor/category/timestamps) using `sqflite` inspector tooling once per release.

## Test Cases & Scenarios
- Receipt review validates required amount, optional vendor/category, and persists edits.
- Dashboard refreshes recent receipts and progress after returning from scans or the full list.
- AchievementService unlocks milestones on first qualifying receipt/savings thresholds.
- Profile updates adjust tax calculations for subsequent scans.
- Negative paths: camera permission denial, OCR returning no totals, cancelling review cleans up temporary image.

## Bug Reports & Status
- All known issues from prior governance audit addressed (missing review step, empty docs, unused scaffolding). Track new defects in GitHub Issues with labels `bug` + `area/*`.

## Quality Metrics
- **Unit/Widget coverage**: maintain ≥80% lines for `lib/core` and `lib/features/*`.
- **Build health**: CI must stay green on `main`; any break requires fix within 1 business day.
- **Crash-free sessions**: Target ≥99% (monitored once telemetry is available).

## Regression Testing Plan
- Run full automated suite before tagging releases.
- Execute manual checklist (receipt scan, review, reward, dashboard refresh, achievements view, profile save) on release candidates.
- Re-run regression after dependency upgrades (Flutter/Dart/plugins).

---
*QA maintained by Core Team | Links: [Execution Log](execution_log.md) → [Governance](governance_traceability.md)*
