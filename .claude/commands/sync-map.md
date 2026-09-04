---
description: Regenerate docs/PROJECT_MAP.md from the current source tree
---

Delegate to the `project-mapper` agent.

Instruct it to regenerate `docs/PROJECT_MAP.md` in full from the
current source tree, following the twelve sections defined in its own
agent file, and to overwrite rather than merge.

When it returns, report only:

- which sections changed since the previous map
- any section it had to leave empty, and why

Do not restate the map's contents. The developer can read the file.
