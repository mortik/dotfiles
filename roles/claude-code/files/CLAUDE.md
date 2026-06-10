# User Preferences

These apply across all projects.

## Commits

Prefer small, focused commits. Each commit should encompass one logical change — don't bundle unrelated edits into a single commit even if they happened in the same session. When staging changes that span multiple concerns, split them into separate commits (e.g., refactor + feature + test fix → three commits, not one).

## Code comments

Keep code comments to a minimum. **Never** write comments that reference exec-plan phases, the current task, the session, or anything procedural about how the code got written.

Bad examples:
- `// Phase 2: add validation`
- `// Per exec-plan step 3`
- `// As discussed in the plan`
- `// Added for the timetable refactor`

Well-named identifiers should explain *what*; comments should only explain *why* when the why is non-obvious (hidden constraint, subtle invariant, bug workaround). A comment that wouldn't make sense to someone reading the file cold — with no knowledge of the task — shouldn't be there.

## Robot signature on external posts

When posting content under the user's identity to an external service — GitHub PR descriptions, PR/issue comments, Slack messages, etc. — **always append a robot emoji** at the end of the text. This is a transparency signal so the audience can tell at a glance that the message was AI-authored.

Exceptions:
- Commit messages: the `Co-Authored-By: Claude` trailer already serves this purpose — don't double-mark.
- Local files, code, and tool output don't need the marker — only content posted under the user's account to an external service.
