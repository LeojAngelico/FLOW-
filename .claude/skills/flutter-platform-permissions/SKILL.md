---
name: flutter-platform-permissions
description: Review and implement Android/iOS platform capabilities and permissions for Flutter features. Use for camera, microphone, location, photos, files, notifications, Bluetooth, biometrics, contacts, background work, deep links, sensors, and other native capabilities.
---

# Platform Capabilities and Permissions

For the packages this project uses for native capabilities and the
permissions actually declared for each platform, read
`docs/PROJECT_MAP.md` § Platform.

## Rule

Every platform-dependent feature is evaluated for **both** Android and
iOS before it is considered complete. Android and iOS permission
behaviour is not equivalent, and assuming it is produces a feature that
works on one platform and fails silently on the other.

## For each capability

1. Confirm the Flutter package supports what is needed on both
   platforms.
2. Add the Android manifest declaration.
3. Add the iOS usage-description key, with a string a reviewer will
   accept — it is shown to the user.
4. Implement the runtime request in context, at the moment the
   capability is needed, not at launch.
5. Handle denied, permanently denied and restricted separately. They
   need different UI: retry, send to Settings, and explain.
6. Handle the permission changing while the app is backgrounded and the
   user returns from Settings.
7. Handle hardware that is absent or unavailable.
8. Consider what happens across app lifecycle transitions.
9. Remember that emulators and simulators do not faithfully reproduce
   permission or hardware behaviour. State plainly that device testing
   is required, and leave it to the developer.

## Restraint

Do not request a permission the feature does not need, and do not
request it earlier than needed. Each unnecessary prompt costs trust and
grants.

When adding a package, inspect its native setup and the permissions it
pulls in before treating the feature as done.
