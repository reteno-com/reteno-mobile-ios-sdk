# iOS SDK workflow In-app implementation plan

Status: planned; native implementation and verification are pending.
Baseline: `862ed2acecc404a1e58572f7950a3dd347d4b672`.
Reconcile the paths below if the implementation branch changes.

Use the [shared SDK contract and regression matrix](../../../esputnik-product-docs/changes/CHG-2026-0002-in-app-workflow-delivery/mobile-sdk-implementation-plan.md)
and [HTTP examples](https://ardas.atlassian.net/wiki/spaces/eS/pages/588021917).
This plan covers iOS SDK changes only. Reuse existing request management,
rule evaluation, presentation, persistence, and retries.

## Implementation steps

| Step | iOS changes | Acceptance |
| --- | --- | --- |
| 1. Models and requests | Extend [InAppMessageLists](../../Reteno/Sources/InAppMessages/Models/InAppMessageLists.swift), [InAppContents](../../Reteno/Sources/InAppMessages/Models/InAppContents.swift), and request adapters. Decode optional `inWorkflow`, IID, and expiry without breaking ordinary responses. Adapt [MobileRequestService](../../Reteno/Sources/Services/MobileRequestService.swift) for discovery `includeWorkflow=true` when workflow support is complete. Keep workflow `messages` and ordinary `messageInstanceIds` content bodies separate. | Two IIDs sharing one snapshot remain distinct beside ordinary entries. Missing/false `inWorkflow` preserves ordinary behavior. No new delivery-method enum, event identifier, or feature flag. |
| 2. Execution state | Extend existing local persistence and request management. Scope pending, rendering, shown, and personalized state by application/account context plus IID; match content by IID and snapshot. Preserve ordinary frequency data during upgrades. | Persistent reopen restores independent executions and queued observations. Account/contact changes cannot display old personalized content or replay observations under new credentials. |
| 3. Eligibility and content | Adapt [InAppService](../../Reteno/Sources/InAppMessages/Services/InAppService.swift) and existing rules. Skip only workflow FREQUENCY. After other conditions pass, request authorized content and apply the prepared JSON map to the raw model. | Failed conditions do not fetch content. Unsupported enabled conditions defer safely. Revalidate online immediately before first rendering, even with cached bytes; recheck absolute expiry and local shown state. Add no SDK TTL default or Velocity engine. |
| 4. Visibility and retry | Update [InAppMessages](../../Reteno/Sources/InAppMessages/InAppMessages.swift), [InAppMessageWebViewController](../../Reteno/Sources/InAppMessages/Controllers/InAppMessageWebViewController.swift), [NewInteraction](../../Reteno/Sources/InAppMessages/Models/NewInteraction.swift), and [NewInAppInteractionRequest](../../Reteno/Sources/Requests/InAppMessages/NewInAppInteractionRequest.swift). Replace fresh UUID allocation only for workflow display. Persist the shown marker and OPENED observation together using existing local storage; reuse the bounded request queue. | Only visible presentation emits OPENED. Fetch/init alone does not. Retry the same server IID, snapshot, UTC-seconds time, and body after lost acknowledgment or restart without redisplay. FAILED before visibility does not mark shown; dismissal remains local. |
| 5. Clicks and certification | Agree on the workflow click transport before implementing CTA changes. Certify web-view/native presentation callbacks and supported wrappers against the same IID semantics. Enable released SDK discovery opt-in only after all required paths are verified. | Current POST CLICKED retains only the action URL downstream; existing PUT preserves CTA metadata but does not update shown state. Record the selected transport and its regression results before release. Steps 1–4 can proceed independently. |

Keep one local presentation guard per workflow IID. Do not collapse queued
observations by IID. Repeated discovery and HTTP 304 must preserve local shown
markers and the original `expiresAt`. Preserve ordinary IID generation,
frequency state, and click handling.

## Verification and completion

Extend [InAppServiceTests](../../RetenoExample/RetenoExampleTests/Tests/InApp/InAppServiceTests.swift)
and [InAppRequestServiceTests](../../RetenoExample/RetenoExampleTests/Tests/InApp/InAppRequestServiceTests.swift),
with controlled visibility/network callbacks and persistent reopen fixtures.
Use fixed time and isolated stores.

Cover mixed ordinary/workflow discovery; two same-snapshot IIDs with different
personalization; rule deferral; failed initialization; actual visibility;
lost response/restart; repeated 200/304; multiple queued observations;
expiry/offline; concurrent presentation; account switching; and existing-data
migration. Confirm that showing E1 leaves E2 independently available.

Run from the repository root on macOS with Xcode after implementation:

```bash
xcodebuild -showdestinations -project RetenoExample/RetenoExample.xcodeproj -scheme RetenoExampleTests
xcodebuild test -project RetenoExample/RetenoExample.xcodeproj -scheme RetenoExampleTests -destination 'platform=iOS Simulator,id=<installed-simulator-id>'
```

Select an installed simulator ID from the first command. Record XCTest and
device results for visible presentation, background/foreground, app
termination, reconnect, clicks, and dismissal. Verify renderer and wrapper
behavior. Completion requires reviewed iOS changes, migration/recovery
evidence, and tested SDK/renderer versions. HTTP success is not a Kafka
acknowledgment; cross-device exactly-once display is not guaranteed.
No XCTest, simulator, or device checks were run to prepare this plan.
