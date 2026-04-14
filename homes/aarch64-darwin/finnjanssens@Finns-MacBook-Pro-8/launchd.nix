{ pkgs, lib, ... }:
let
  # Restricted settings for the meeting minutes processor
  # Only allows reading from Quill MCP and writing to specific Obsidian meeting folders
  meetingProcessorSettings = pkgs.writeText "meeting-processor-settings.json" (
    builtins.toJSON {
      permissions = {
        defaultMode = "deny";
        allow = [
          # Quill MCP read-only tools
          "mcp__quill__list_meetings"
          "mcp__quill__search_meetings"
          "mcp__quill__get_meeting"
          "mcp__quill__get_transcript"
          "mcp__quill__get_minutes"
          "mcp__quill__list_meeting_types"
          "mcp__quill__get_meeting_type"
          "mcp__quill__list_contacts"
          "mcp__quill__search_contacts"
          "mcp__quill__get_contact"
          "mcp__quill__list_events"
          "mcp__quill__get_event"

          # Restricted filesystem access
          "Read(/Users/finnjanssens/Personal/obsidian/**)"
          "LS(/Users/finnjanssens/Personal/obsidian/**)"
          "Glob(/Users/finnjanssens/Personal/obsidian/**)"
          "Write(/Users/finnjanssens/Personal/obsidian/ITP/meetings/**)"
          "Write(/Users/finnjanssens/Personal/obsidian/ITP/Daikin/meetings/**)"
          "Write(/Users/finnjanssens/Personal/obsidian/ITP/Backend Practice/Meetings/**)"
          "Edit(/Users/finnjanssens/Personal/obsidian/ITP/meetings/**)"
          "Edit(/Users/finnjanssens/Personal/obsidian/ITP/Daikin/meetings/**)"
          "Edit(/Users/finnjanssens/Personal/obsidian/ITP/Backend Practice/Meetings/**)"

          # Directory creation for new recurring meeting folders
          "Bash(mkdir -p /Users/finnjanssens/Personal/obsidian/ITP/meetings/*)"
          "Bash(mkdir -p /Users/finnjanssens/Personal/obsidian/ITP/Daikin/meetings/*)"
          "Bash(mkdir -p /Users/finnjanssens/Personal/obsidian/ITP/Backend Practice/Meetings/*)"
        ];
        deny = [
          "Bash(rm:*)"
          "Bash(mv:*)"
          "Bash(cp:*)"
          "WebFetch(*)"
          "WebSearch"
        ];
      };
    }
  );

  # Restricted settings for the obsidian tagger
  # Only allows reading and editing files within the obsidian vault
  obsidianTaggerSettings = pkgs.writeText "obsidian-tagger-settings.json" (
    builtins.toJSON {
      permissions = {
        defaultMode = "deny";
        allow = [
          "Read(/Users/finnjanssens/Personal/obsidian/**)"
          "Edit(/Users/finnjanssens/Personal/obsidian/**)"
          "Write(/Users/finnjanssens/Personal/obsidian/**)"
          "Glob(/Users/finnjanssens/Personal/obsidian/**)"
          "Grep(/Users/finnjanssens/Personal/obsidian/**)"
          "LS(/Users/finnjanssens/Personal/obsidian/**)"
          "Bash(ls /Users/finnjanssens/Personal/obsidian/*)"
          "Bash(find /Users/finnjanssens/Personal/obsidian/*)"
        ];
        deny = [
          "Bash(rm:*)"
          "Bash(mv:*)"
          "Bash(cp:*)"
          "WebFetch(*)"
          "WebSearch"
        ];
      };
    }
  );

  # Generate StartCalendarInterval entries for each weekday (Mon-Fri) at each hour (7-18)
  workdayHourlyIntervals = lib.flatten (
    map (
      weekday:
      map (hour: {
        Weekday = weekday;
        Hour = hour;
        Minute = 0;
      }) (lib.range 7 18)
    ) (lib.range 1 5)
  );

  checkMrsScript = pkgs.writeShellScript "check-mrs" ''
    set -euo pipefail

    OUTPUT_FILE="/Users/finnjanssens/Personal/obsidian/ITP/Daikin/Merge Request Reviews.md"
    HOSTS=("gitlab.com" "git.inthepocket.org")
    GLAB="${pkgs.glab}/bin/glab"
    JQ="${pkgs.jq}/bin/jq"
    SED="${pkgs.gnused}/bin/sed"

    updated=$(${pkgs.coreutils}/bin/date "+%Y-%m-%d %H:%M")

    ${pkgs.coreutils}/bin/printf -- "---\nupdated: %s\n---\n\n# MRs Awaiting Review\n" "$updated" > "$OUTPUT_FILE"

    for host in "''${HOSTS[@]}"; do
      ${pkgs.coreutils}/bin/printf "\n## %s\n\n" "$host" >> "$OUTPUT_FILE"

      mrs=$(GITLAB_HOST="$host" "$GLAB" api "merge_requests?reviewer_username=finn.janssens&state=opened&scope=all" 2>/dev/null | "$SED" 's/[[:cntrl:]]//g' || echo "[]")

      if [ -z "$mrs" ] || [ "$mrs" = "[]" ]; then
        echo "No open MRs awaiting review." >> "$OUTPUT_FILE"
      else
        ${pkgs.coreutils}/bin/printf '%s' "$mrs" | "$JQ" -r '
          sort_by(.created_at) |
          .[] |
          (.web_url | split("/") | .[-4] // empty) as $project |
          "- [ ] **\($project)** [\(.title)](\(.web_url)) by \(.author.username) ➕ \(.created_at | split("T")[0]) #review"
        ' >> "$OUTPUT_FILE"
      fi
    done
  '';
in
{
  # Daily MR review checker (runs at 08:00 local time)
  launchd.agents.mr-review-checker = {
    enable = true;
    config = {
      ProgramArguments = [ "${checkMrsScript}" ];
      StartCalendarInterval = [
        {
          Hour = 8;
          Minute = 0;
        }
      ];
      StandardOutPath = "/tmp/mr-review-checker.log";
      StandardErrorPath = "/tmp/mr-review-checker.err";
      EnvironmentVariables = {
        HOME = "/Users/finnjanssens";
      };
    };
  };

  # Meeting minutes processor (runs hourly Mon-Fri, 7am-6pm)
  # Uses Quill MCP to find new meetings and writes them to the Obsidian vault
  launchd.agents.meeting-minutes-processor = {
    enable = true;
    config = {
      ProgramArguments = [
        "/etc/profiles/per-user/finnjanssens/bin/claude"
        "--print"
        "--settings"
        "${meetingProcessorSettings}"
        "--permission-mode"
        "acceptEdits"
        "--max-budget-usd"
        "1.00"
        ''
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
             time: HH:MM
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

          5. For the "My Tasks" section, ONLY include action items that are
             explicitly assigned to me (Finn Janssens, also known as Finn).
             Look for phrases like "Finn will...", "Finn to...", "@finn", or
             tasks where I committed to doing something. Exclude tasks
             assigned to other people or unassigned/group tasks.

          6. Use proper Obsidian Tasks plugin syntax. Every task must have
             both the #task and #quill tags:
             - [ ] Task text 📅 YYYY-MM-DD (due date if mentioned) #task #quill

          Skip meetings that already have a file at the target path.
          Report a summary of what was processed.
        ''
      ];
      WorkingDirectory = "/Users/finnjanssens/Personal/obsidian";
      StartCalendarInterval = workdayHourlyIntervals;
      StandardOutPath = "/tmp/meeting-minutes-processor.log";
      StandardErrorPath = "/tmp/meeting-minutes-processor.err";
      EnvironmentVariables = {
        HOME = "/Users/finnjanssens";
        PATH = "/etc/profiles/per-user/finnjanssens/bin:/run/current-system/sw/bin:/usr/bin:/bin";
      };
    };
  };

  # Daily Obsidian note tagger (runs at 21:00 local time)
  launchd.agents.obsidian-tagger = {
    enable = true;
    config = {
      ProgramArguments = [
        "/etc/profiles/per-user/finnjanssens/bin/claude"
        "--print"
        "--settings"
        "${obsidianTaggerSettings}"
        "--permission-mode"
        "acceptEdits"
        "--max-budget-usd"
        "0.50"
        "Find all markdown files that are missing YAML frontmatter tags. For each untagged note, read its content and add appropriate tags following the rules in CLAUDE.md. Report a summary of what was tagged."
      ];
      WorkingDirectory = "/Users/finnjanssens/Personal/obsidian";
      StartCalendarInterval = [
        {
          Hour = 21;
          Minute = 0;
        }
      ];
      StandardOutPath = "/tmp/obsidian-tagger.log";
      StandardErrorPath = "/tmp/obsidian-tagger.err";
    };
  };
}
