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

in
{
  # Daily MR review checker (runs at 08:00 local time)
  launchd.agents.mr-review-checker = {
    enable = true;
    config = {
      ProgramArguments = [ "${../../../scripts/check-mrs.sh}" ];
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
        PATH = "/etc/profiles/per-user/finnjanssens/bin:/run/current-system/sw/bin:/usr/bin:/bin";
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
        (builtins.readFile ../../../scripts/prompts/meeting-minutes.md)
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
        (builtins.readFile ../../../scripts/prompts/obsidian-tagger.md)
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
