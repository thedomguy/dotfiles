---
name: capture
description: The user is telling Jarvis something to keep: a new task, reminder, note, idea or thing to remember ("remind me to…", "add a task to…", "note that…", "I need to…", "idea:…"). Not questions, and not changes to existing items.
kind: capture
---
Saved with Jarvis' own voice extraction (POST /api/capture/voice), the same path the web app's
voice capture uses. No model runs on this machine for it, so this text is documentation only.
Set `enabled: false` above to send everything to the agent jobs instead.
