# Troubleshooting

## Troubleshooting

**"Gradle sync failed" / `resValue` errors on Android** — AGP 9
requires `buildFeatures { resValues = true }` (already set in
`android/app/build.gradle.kts`); if you see "Product Flavor ... contains
custom resource values, but the feature is disabled," that block was
removed or the file was reverted.

**Wrong app/API when running `--flavor <x>`** — confirm
`AppEnvironment._resolveFlavor()` actually maps every `appFlavor`
string to the right `AppFlavor` enum value, and that you passed
`--flavor` at all (omitting it silently defaults to `dev`).

**Wrong application ID / can't install dev and prod side by side** —
check `android/app/build.gradle.kts`'s `productFlavors` block for the
expected `applicationIdSuffix`; a mismatch there is the only thing
that would cause two flavors to collide.

**Wrong bundle identifier on iOS** — check that the target Xcode
*scheme* (`dev`/`alpha`/`prod`) is actually selected, not just the
build configuration; each scheme's Run/Profile/Archive actions must
point at the matching `Debug-<flavor>`/`Release-<flavor>`/
`Profile-<flavor>` configuration.

**`xcodebuild`/scheme not found** — schemes must be **shared** (under
`xcshareddata/xcschemes/`, not user-specific `xcuserdata/`) for
`flutter run --flavor <x>` to find them; all three (`dev`/`alpha`/
`prod`) already are.

**iOS build fails after editing `project.pbxproj` by hand** — don't.
Use the `xcodeproj` Ruby gem (`gem install xcodeproj`) to script
changes, verify with `xcodebuild -list -project ios/Runner.xcodeproj`
afterward, and keep a backup — hand-editing this file risks silent
corruption with no clear error until a much later build step.

**UI Playground not appearing** — check
`AppEnvironment.current.enableUiPlayground` for the flavor/build-mode
combination you're running (it's intentionally `false` for `prod` and
for `devRelease`) — see [Environments & Flavors](builds-and-flavors.md#environments--flavors).

**Routing seems to skip a screen / redirect loop** — check
`app_router.dart`'s top-level `redirect:` against
`authSessionNotifierProvider`'s current `AuthSessionStatus` — most
navigation bugs here trace back to a session-status transition, not
the route table itself.

**State doesn't update after an action** — confirm the Notifier method
actually reassigns `state = state.copyWith(...)` (Riverpod's
`Notifier` only rebuilds listeners on reassignment, not in-place
mutation of a field).

**Login/refresh loop or unexpected logout** — check
`AuthInterceptor.onError` (`core/network/auth_interceptor.dart`) — the
`hasRetriedRequestKey`/`isRequestKey` flags in `AppConstants` prevent
infinite retry loops; a bug here usually means one of those flags
isn't being set on the retried request.

**A widget looks unthemed / wrong color** — confirm it's actually
using a `core/ui_kit/` component or reading
`Theme.of(context).colorScheme`, not a leftover hardcoded `Colors.*`
value.

**Layout overflow (red/yellow stripes)** — check whether the
overflowing widget is inside a `Row`/`Column` with `Expanded` siblings
and no `Flexible`/ellipsis handling on text — this exact bug happened
in `AppButton` (long label + icon in a constrained `Row`) and was
fixed by wrapping the label in `Flexible` with `overflow: TextOverflow.ellipsis`.

**Release build fails only in `--release`, not `--debug`** — usually
tree-shaking or a signing config issue, not a logic bug; check
`flutter build apk --flavor <x> --release` output directly rather than
assuming it's the same failure as debug.

## Debug Tools

| Tool | What it is | Available in |
|---|---|---|
| UI Playground | Component showcase (see above) | `devDebug`, `alphaDebug`, `alphaRelease` — never `prod` |
| Verbose HTTP logging | Full request/response logging via `RedactedLogInterceptor` | `dev` only |
| Environment ribbon | Corner banner showing "DEVELOPMENT"/"ALPHA" | `dev`, `alpha` (debug and release) — never `prod` |

**Developer tooling** (UI Playground, verbose logs) exists purely to
help build/debug the app and must never reach real users — that's why
everything above is gated through `AppEnvironment`, not a screen-level
`if (kDebugMode)` that a flavor could accidentally bypass.
**Internal QA tooling** (the environment ribbon, moderate logging, the
Playground in `alpha`) is intentionally available in `alpha` release
builds too, since QA needs to test release-mode behavior.
**Production functionality** is everything else — it must work
identically regardless of which of the above tools happen to be
compiled in.

