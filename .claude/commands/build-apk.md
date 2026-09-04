---
description: Build a phone-only (arm64) Android APK with a versioned filename
argument-hint: [dev|alpha|prod] [debug|release]
---

Run `scripts/build_apk.sh $ARGUMENTS` (no arguments defaults to
`dev release`).

Report only the output path and file size the script prints. Do not
improvise the build flags or the output filename inline — if the
naming convention or ABI scoping ever needs to change, edit
`scripts/build_apk.sh` itself so every future build, from this command
or the terminal directly, stays consistent.
