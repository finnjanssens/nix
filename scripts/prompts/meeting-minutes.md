Use the Quill MCP to find any meetings that ended within the last 2 hours
and have transcripts/minutes available.

For each new meeting:
1. Determine the meeting type:
   - If the meeting title or participants mention "Daikin" or it relates
     to the Daikin Onecta Cloud project, it's a Daikin meeting
   - If the meeting is about backend practice topics (backend engineering
     guild, backend syncs, backend chapter, tech practice meetings),
     it's a Backend Practice meeting
   - Otherwise it's a general work meeting

2. Determine the recurring meeting name (e.g. "Standup", "Sync", "Retro").
   If it's a one-off meeting, use the meeting title.

3. Generate a markdown file with this structure:

   ```
   ---
   date: YYYY-MM-DD
   time: HH:MM (in Europe/Brussels timezone, convert from UTC if needed)
   duration: X minutes
   participants: [Name 1, Name 2]
   tags: [meeting]
   ---

   # <Meeting Title>

   ## Summary
   <2-3 sentence summary of the meeting>

   ## Key Discussion Points
   <bulleted list>

   ## My Tasks
   - [ ] Task description 📅 YYYY-MM-DD #task #quill

   ## Original Notes
   <Quill's AI-generated notes>
   ```

4. Write the file to:
   - Daikin meetings: /Users/finnjanssens/Personal/obsidian/ITP/Daikin/meetings/<recurring-meeting-name>/YYYY-MM-DD-<title>.md
   - Backend Practice meetings: /Users/finnjanssens/Personal/obsidian/ITP/Backend Practice/Meetings/<recurring-meeting-name>/YYYY-MM-DD-<title>.md
   - Other meetings: /Users/finnjanssens/Personal/obsidian/ITP/meetings/YYYY-MM-DD-<title>.md

5. For the "My Tasks" section, be VERY strict. Only include a task if
   the transcript or notes contain an EXPLICIT, unambiguous assignment
   to me (Finn Janssens / Finn). Valid examples:
   - "Finn will look into X"
   - "Finn, can you handle X?"
   - "I'll take care of X" (where "I" is clearly Finn speaking)

   Do NOT include:
   - Tasks assigned to other people
   - Group/team tasks ("we should...", "the team needs to...")
   - Unassigned tasks or general action items
   - Tasks where Finn is only mentioned but not the assignee

   When in doubt, leave it out. An empty "My Tasks" section is fine.

6. Use proper Obsidian Tasks plugin syntax. Every task must have
   both the #task and #quill tags:
   - [ ] Task text 📅 YYYY-MM-DD (due date if mentioned) #task #quill

Skip meetings that already have a file at the target path.
Report a summary of what was processed.
