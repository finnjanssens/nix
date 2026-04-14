{ ... }:
{
  # Daily MR review checker (runs at 08:00 local time)
  # Invokes the /user:check-mrs claude command
  launchd.agents.mr-review-checker = {
    enable = true;
    config = {
      ProgramArguments = [
        "/etc/profiles/per-user/finnjanssens/bin/claude"
        "--print"
        "--permission-mode"
        "acceptEdits"
        "--max-budget-usd"
        "0.50"
        "/user:check-mrs"
      ];
      WorkingDirectory = "/Users/finnjanssens/Personal/obsidian";
      StartCalendarInterval = [
        {
          Hour = 8;
          Minute = 0;
        }
      ];
      StandardOutPath = "/tmp/mr-review-checker.log";
      StandardErrorPath = "/tmp/mr-review-checker.err";
      EnvironmentVariables = {
        PATH = "/etc/profiles/per-user/finnjanssens/bin:/run/current-system/sw/bin:/usr/bin:/bin";
        HOME = "/Users/finnjanssens";
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
