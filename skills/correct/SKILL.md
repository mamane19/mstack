---
name: correct
description: Find the mistakes agents keep repeating here and make each one impossible, with architecture first, then types, then a check whose error names the fix, then a test, and written rules last. Use for /correct.
disable-model-invocation: true
triggers: [user]
---

# Correct

I keep correcting agents for the same mistakes. Change the repo, or my standard, so the next agent cannot make them.

Assume every contributor is an agent that sees only the files it opened, copies the nearest example, and takes the shortest path that runs.

## Find the mistake classes

1. Read the recent corrections: my review comments, reverted commits, rejected PRs, and the corrections in this conversation.
2. Read the agent instruction files that apply here.
3. Group the mistakes into classes. A class counts once it has happened twice.

## Fix each class at the highest level that works

1. **Architecture.** Give each piece of state one owner and each task one supported way. Replace hand-synced lists with one source of truth. Delete the old way and the dead code an agent would copy.
2. **Types.** Make the bad state impossible to write.
3. **A check.** If bad code still runs, add a lint, script, or CI step. Its error names the file, type, or function to use instead. If the pattern is already common, fail only when a change adds more of it.
4. **A test.** Test the behaviour. Fix or delete any test that would still pass if every function it calls returned nothing.
5. **A written rule, last.** Use it only for judgment calls. Nothing fails when an agent skips a written rule.

## Fix and prove

- Fix the most frequent classes now, one commit each.
- Prove each new check fails on a real past mistake. Show the command and its output.
- Run the same command locally and in CI.
- An exception goes on the offending line, with a reason, an expiry date, and a human's approval.

## Keep the rule table

Keep a table of each rule and what enforces it, in the right file:

- A rule about one repo goes in that repo's `AGENTS.md`, through a reviewed PR.
- A rule about how I work everywhere goes in my mstack `AGENTS.md`.

When I correct you, fix the mistake and add the rule.

If the rule was already there and nothing enforces it, that is a repeat. Fix it at the highest level in the same change.

Drop a rule once its mistake can no longer happen.

## Reply

For each class: the evidence, the level you picked, and why a higher level did not work.
