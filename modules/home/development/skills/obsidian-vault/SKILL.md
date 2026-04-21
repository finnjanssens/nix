---
name: obsidian-vault
description: Access the user's Obsidian vault for meeting notes, refinement documents, and knowledge base lookups
---

# Obsidian Vault

The user's Obsidian vault is available at `~/Personal/obsidian/`. Use this as a reference when the user asks about meeting notes, refinement working documents, knowledge base entries, or any personal/work notes.

## Vault structure

```
~/Personal/obsidian/
  ITP/
    Backend Practice/
      Meetings/          -- Backend practice meeting notes
    Daikin/
      Knowledge Base/    -- Daikin domain knowledge, architecture notes, decisions
      Meetings/          -- Daikin project meeting notes
      Refinement/        -- Refinement working documents, ticket breakdowns
      Merge Request Reviews.md
  Personal/              -- Personal notes
  Tasks.md               -- Task tracking
```

## When to use

- The user asks about a meeting, discussion, or decision that was documented
- The user references a refinement, ticket breakdown, or working document
- The user needs context from their knowledge base (architecture decisions, domain knowledge)
- The user asks to search their notes for a topic
- The user asks about merge request reviews or feedback

## How to use

1. Use `Glob` to find relevant files by pattern (e.g., `~/Personal/obsidian/ITP/Daikin/Meetings/*.md`)
2. Use `Grep` to search note contents for specific topics
3. Use `Read` to read the full content of a specific note
4. When searching, try multiple relevant subdirectories since the user may not specify the exact location
