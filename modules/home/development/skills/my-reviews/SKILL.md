---
name: my-reviews
description: List GitLab merge requests awaiting your review with age and TL;DR summaries. Use when user asks about pending reviews, MRs to review, or review queue.
---

# My Reviews

## Overview

Fetches open GitLab merge requests where you are assigned as a reviewer, summarizes each one with how long it has been waiting and a short TL;DR of the changes.

## When to Use This Skill

Activate when the user asks about:
- Pending MR reviews
- "What do I need to review?"
- Review queue or backlog
- Open MRs assigned to them

## Workflow

### Step 1: Fetch MRs

Run the following command to get all open MRs where you are a reviewer:

```bash
glab mr list --reviewer=@me --group=daikin-edc-electrics/projects/cloud-projects --not-draft --output=json
```

If the command returns an empty array (`[]`), report that there are no MRs awaiting review and stop.

### Step 2: Parse and Summarize

For each MR in the JSON output, extract:

- **Title**: from `title`
- **Author**: from `author.name`
- **Project**: extract the project name from `references.full` (the segment before the `!` in the full reference, take only the last path component)
- **URL**: from `web_url`
- **Age**: compute from `created_at` relative to today's date. Express as "X days" or "X hours" depending on the duration.
- **Status**: from `detailed_merge_status` (e.g. `not_approved`, `mergeable`, `discussions_not_resolved`)
- **TL;DR**: read the `description` field and write a single-sentence summary (max ~15 words) of what the MR implements or changes. Strip markdown images/screenshots. If the description is empty, use the title as the summary.

### Step 3: Present

Present the results as a markdown table sorted by age (oldest first):

```
| MR | Project | Author | Age | Status | TL;DR |
|----|---------|--------|-----|--------|-------|
| [Title](url) | project-name | Author Name | 5 days | not_approved | Short summary of changes |
```

After the table, add a one-line total: "**X merge requests awaiting review**"

## Notes

- Do NOT fetch diffs or make API calls per MR. All information comes from the single `glab mr list` call.
- Draft MRs are excluded via `--not-draft`.
- The group path `daikin-edc-electrics/projects/cloud-projects` covers all Daikin cloud projects.
