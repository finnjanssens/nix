# Global CLAUDE.md

## About me

- Software engineer at In The Pocket
- Working across personal and work projects on macOS (Apple Silicon)

## Response style

- Respond in English
- Be detailed and thorough with explanations and context

## Workflow preferences

- Use conventional commits: `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`
- Group changes into logical commits (e.g. separate module additions from config tweaks)
- Suggest a commit after completing work, but wait for explicit approval before committing
- Always verify changes work before suggesting a commit

## Communication

- Avoid using dashes (--) in generated text, use commas or separate sentences instead
- Avoid heavy use of emojis in Slack messages

## Obsidian vault

My Obsidian vault is at `~/Personal/obsidian/` (configured as an additional directory, always readable). Use it to look up meeting notes, refinement working documents, knowledge base entries, and personal notes. Structure:

- `ITP/Daikin/Meetings/`: Daikin project meeting notes
- `ITP/Daikin/Knowledge Base/`: domain knowledge, architecture decisions
- `ITP/Daikin/Refinement/`: ticket breakdowns, refinement working documents
- `ITP/Backend Practice/Meetings/`: backend practice meeting notes
- `Personal/`: personal notes
- `Tasks.md`: task tracking

When I ask about meetings, decisions, refinements, or notes, search the vault with Glob and Grep before answering.

When you encounter knowledge worth preserving during our work (e.g. architecture decisions, non-obvious system behavior, debugging insights, domain concepts, API quirks, infrastructure details), proactively suggest adding it to the appropriate Knowledge Base folder in the Obsidian vault. Keep suggestions brief, e.g. "This would be worth capturing in `ITP/Daikin/Knowledge Base/`, want me to write it up?" Only suggest when the knowledge is non-trivial and not already documented.

## Secrets

- Never commit tokens or credentials
- Use macOS Keychain for secret storage where possible
