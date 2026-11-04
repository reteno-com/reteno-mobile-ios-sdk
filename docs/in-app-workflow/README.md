# iOS SDK InApp delivery plan and implementation

Status: November 4, 2026 working-tree refinement. Source changes implement the
approved contract below; native certification and release are pending. Earlier
six-pass review records cover the previous contract.

The [shared handoff](../../../esputnik-product-docs/changes/CHG-2026-0002-in-app-workflow-delivery/mobile-sdk-implementation-plan.md) and
[mobile contract](../../../esputnik-product-docs/changes/CHG-2026-0002-in-app-workflow-delivery/interfaces/mobile-in-app-executions/README.md) own
cross-platform behavior. This document covers iOS implementation only.

## Implementation and acceptance

| Area | Current implementation | Acceptance |
| --- | --- | --- |
| Discovery | Optional IID, absolute expiry, and backend priority. No workflow flag or query opt-in. | Mixed ordinary/server entries, distinct IIDs sharing a snapshot, legacy response defaults. Backend isolates unsupported SDK versions. |
| Content | Received IID selects online IID/snapshot content authorization. Ordinary snapshots retain their existing content request. | Original IID, raw snapshot, prepared per-delivery personalization; no cross-account or offline first display. |
| Rules and priority | Evaluate the prepared rules normally. Higher backend priority wins among eligible candidates; default priority is 10. | Priority 20 beats 10, failed eligibility permits fallback, and asynchronous eligibility cannot invert priority. Visible UI is not preempted. |
| Local state | Existing account-scoped storage retains IID, expiry, suppression, and separate queued observations. | Restart, identity switch, repeated discovery, and lost acknowledgment do not redisplay a completed IID. |
| Observations | Standalone InApp OPENED/CLICKED/FAILED use POST. `serverAssignedIid` reflects received versus generated identity and is retained with retries. | Preserve original IID/time/body and complete CTA; missing/false provenance follows ordinary processing. Push transport stays unchanged. |
| Failure | OPENED, CLICKED, and FAILED establish local suppression for a received IID. | Server synchronously ends contact availability; local state survives ACK loss, queue exhaustion, and reopen. |

The SDK has no workflow business mode, TTL default, or Velocity engine. It
applies the sender's prepared JSON values and reports OPENED only after actual
visibility. A content fetch or initialization alone is not OPENED. Dismissal
stays local. Backend state update precedes analytics publication; see the
shared acknowledgment contract for partial failure and retries.

## Remaining acceptance

Run native tests, render on devices, certify supported wrappers and renderer
versions, and exercise sender → SDK → analytics with real services. Verify
upgrade from released local storage, account isolation, pause/resume,
backgrounding, native loading failures, and late CTA events. Configure backend
minimum SDK versions only after those versions are certified. This plan does
not authorize publication or deployment.

## iOS implementation and verification

[InAppService](../../Reteno/Sources/InAppMessages/Services/InAppService.swift)
authorizes server content and reuses the current rule and schedule checks.
[InAppMessages](../../Reteno/Sources/InAppMessages/InAppMessages.swift) uses the
existing UIKit presenter, scheduler, and main queue. Priority arbitration waits
for a higher-priority asynchronous candidate before choosing a lower one.
Pending callbacks are invalidated by account/context changes and cancellation.

Existing KeyValueStorage retains suppression and queued observations together.
The stored state key and legacy encoded provenance key remain readable; wire
JSON uses `serverAssignedIid`. The scheduler keeps its eight-attempt bounded
retry behavior. Contact-registration barriers survive restart and use captured
context/authentication, so old events cannot be replayed under new credentials.

## Review findings and resolutions

The November 4 contract-alignment and follow-up reviews identified the following
iOS issues. All are fixed in the current working tree. The latest approved
follow-up adds authorization-refresh and postponed-priority regressions to the
earlier six fixes. Its second review found no further actionable issues in the
affected scope.

| Finding | Failure scenario | Resolution |
| --- | --- | --- |
| Ordinary clicks are not retried reliably | A failed ordinary CLICKED request can be lost instead of surviving for replay. | Use the existing persisted observation queue for ordinary clicks, preserving the IID, full CTA data, original account, and authentication context. |
| Pause does not cancel pending server presentation | A server delivery finishes authorization or renderer preparation after pause and can still appear. | Invalidate pending callbacks and cancel unfinished server presentation. Already visible UI and ordinary pause behavior retain their existing handling. |
| FAILED suppression test contradicts the contract | The test expects a server delivery to remain eligible after FAILED and then emit OPENED. | Update the test to expect terminal suppression. This is a test correction; production suppression behavior is unchanged. |
| Server-only refresh discards ordinary candidates | Resume refreshes server deliveries while an ordinary candidate waits for a segment response. Clearing the whole queue removes its token, so the late eligible result is ignored. | Cancel only server candidates during server-only refresh. A full discovery refresh still replaces the whole candidate set. |
| Early actions use a different IID from OPENED | CLICK or OPEN_URL arrives before visibility assigns the ordinary IID; the snapshot ID is used instead. | Allocate one ordinary UUID before renderer loading and reuse it for early actions and the later visibility-only OPENED. Each render gets a new UUID; unknown callbacks retain the active UUID. Push and server-assigned identities are preserved. |
| Short backgrounding discards ordinary candidates | Background cancellation clears an ordinary candidate awaiting a segment response. A short foreground return refreshes only server deliveries and does not start a new session to restore it. | Cancel only server candidates on backgrounding. Preserve ordinary tokens while retaining server callback invalidation and unfinished-renderer dismissal. |
| Candidate replacement strands server authorization | Discovery or a short foreground refresh replaces a server candidate while its content authorization is pending. The replacement is rejected as a duplicate, and the old response resolves a discarded token. | Cancel pending authorization and advance the existing presentation generation before replacing candidates. Stale segment callbacks cannot authorize discarded server candidates; server-only refresh still preserves ordinary tokens. |
| Resumed ordinary messages bypass priority | Resume starts priority-20 server authorization, then directly presents a postponed priority-10 ordinary message, including when its segment response arrives first. | Submit the first postponed ordinary message through the existing offer and priority queue. Preserve segment checks and record ordinary frequency only when the message is selected. |

The production fixes remain in
[InAppMessages](../../Reteno/Sources/InAppMessages/InAppMessages.swift) and
[InAppService](../../Reteno/Sources/InAppMessages/Services/InAppService.swift).
The [request service tests](../../RetenoExample/RetenoExampleTests/Tests/InApp/InAppRequestServiceTests.swift)
record ordinary click retry expectations, and the
[service tests](../../RetenoExample/RetenoExampleTests/Tests/InApp/InAppServiceTests.swift)
record terminal FAILED suppression expectations.

## Verification results

| Check | Result |
| --- | --- |
| Swift 5.9.2 parsing | Current source parses successfully. This is not an iOS build. |
| Extracted-production Foundation harness | The final run passed 77 assertions: all earlier 41 plus 36 authorization-refresh and resume-priority checks. It executes the affected refresh, pause/resume, queue, frequency processing, renderer setup, script handler, service, and storage method bodies with controlled UIKit/WebKit and network boundaries. |
| Regression reproduction | The latest extension reproduced 21 failing assertions before the two approved fixes, with all earlier 41 still passing. After the fixes, all 77 assertions passed. Earlier passes changed 15 failures to 34 passing assertions, then one background failure to 41 passing assertions. These counts describe successive runs, not separate native test suites. |
| Covered boundaries | Delayed ordinary segment responses, full and server-only refresh during authorization, stale response and segment rejection, short foreground recovery, postponed ordinary priority, authorization-failure fallback, rejected-segment fallback, frequency processing after selection, early CLICK/OPEN_URL, visibility-only OPENED, fresh per-render IID, push/server identity, pending renderer cancellation, and visible server preservation. |
| Native UIKit/WebKit/XCTest | Pending on macOS/Xcode. Parsing and the isolated harness do not establish native rendering behavior. |

Run the existing RetenoExample XCTest scheme on a supported simulator, then
verify device visibility, bridge callbacks, slide-up/window handling, and
interactions. Linux parsing does not establish those native behaviors.
