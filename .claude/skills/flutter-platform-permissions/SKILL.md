---
name: flutter-platform-permissions
description: Review and implement Android/iOS platform capabilities and permissions for Flutter features. Use for camera, microphone, location, photos, files, notifications, Bluetooth, biometrics, contacts, background work, deep links, sensors, and other native capabilities.
---

# Android + iOS Platform Workflow

Every platform-dependent feature must be evaluated for both Android and iOS.

Check:

1. Flutter API/package support
2. Android configuration
3. iOS configuration
4. permission declarations
5. runtime permission flow
6. denied/permanently denied/restricted states
7. permission changes after returning from Settings
8. unavailable hardware
9. app lifecycle
10. simulator/emulator limitations

Do not request permissions unnecessarily.

Request permissions in context and handle failure gracefully.

When adding a package, inspect its Android/iOS native setup and permission requirements before considering the feature complete.

Do not assume Android and iOS permission behavior is equivalent.
