{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.claude-code;

  # Base safe operations, always allowed regardless of profile
  baseAllow = [
    # Core Claude Code tools
    "Glob(*)"
    "Grep(*)"
    "LS(*)"
    "Read(*)"
    "Search(*)"
    "Task(*)"
    "TodoWrite(*)"

    # Safe read-only git commands
    "Bash(git status:*)"
    "Bash(git log:*)"
    "Bash(git diff:*)"
    "Bash(git show:*)"
    "Bash(git branch:*)"
    "Bash(git remote:*)"

    # Safe file system operations
    "Bash(ls:*)"
    "Bash(find:*)"
    "Bash(cat:*)"
    "Bash(head:*)"
    "Bash(tail:*)"

    # Safe nix read operations
    "Bash(nix eval:*)"
    "Bash(nix flake show:*)"
    "Bash(nix flake metadata:*)"
  ];

  # Standard profile additions, balanced permissions
  standardAllow = baseAllow ++ [
    # File editing tools
    "Edit(*)"
    "Write(*)"

    # Git operations
    "Bash(git add:*)"
    "Bash(git commit:*)"
    "Bash(git worktree:*)"

    # Safe nix commands
    "Bash(nix build:*)"
    "Bash(nix flake check:*)"
    "Bash(nix flake lock:*)"
    "Bash(nix flake update:*)"
    "Bash(nix search:*)"
    "Bash(nix run nixpkgs#:*)"
    "Bash(nix shell nixpkgs#:*)"

    # Directory creation and file utilities
    "Bash(mkdir:*)"
    "Bash(chmod:*)"
    "Bash(wc:*)"
    "Bash(xargs:*)"
    "Bash(zip:*)"
    "Bash(unzip:*)"

    # Search tools
    "Bash(rg:*)"
    "Bash(grep:*)"

    # Common development tools
    "Bash(npm:*)"
    "Bash(npx:*)"
    "Bash(node:*)"
    "Bash(python3:*)"
    "Bash(pip3 install:*)"
    "Bash(terraform plan:*)"
    "Bash(terraform fmt:*)"
    "Bash(terraform validate:*)"
    "Bash(terraform init:*)"

    # GitHub CLI, read-only operations
    "Bash(gh auth status:*)"
    "Bash(gh api:*)"
    "Bash(gh browse:*)"
    "Bash(gh issue list:*)"
    "Bash(gh issue view:*)"
    "Bash(gh issue status:*)"
    "Bash(gh pr list:*)"
    "Bash(gh pr view:*)"
    "Bash(gh pr diff:*)"
    "Bash(gh pr status:*)"
    "Bash(gh pr checks:*)"
    "Bash(gh repo view:*)"
    "Bash(gh repo list:*)"
    "Bash(gh release list:*)"
    "Bash(gh release view:*)"
    "Bash(gh run list:*)"
    "Bash(gh run view:*)"
    "Bash(gh search:*)"

    # GitLab CLI, read-only operations
    "Bash(glab auth status:*)"
    "Bash(glab mr list:*)"
    "Bash(glab mr view:*)"
    "Bash(glab mr diff:*)"
    "Bash(glab mr approvers:*)"
    "Bash(glab mr issues:*)"
    "Bash(glab issue list:*)"
    "Bash(glab issue view:*)"
    "Bash(glab issue board:*)"
    "Bash(glab ci list:*)"
    "Bash(glab ci view:*)"
    "Bash(glab ci status:*)"
    "Bash(glab ci get:*)"
    "Bash(glab ci lint:*)"
    "Bash(glab ci trace:*)"
    "Bash(glab ci artifact:*)"
    "Bash(glab ci config:*)"
    "Bash(glab pipeline list:*)"
    "Bash(glab pipeline view:*)"
    "Bash(glab pipeline status:*)"
    "Bash(glab repo view:*)"
    "Bash(glab repo list:*)"
    "Bash(glab repo search:*)"
    "Bash(glab repo contributors:*)"
    "Bash(glab release list:*)"
    "Bash(glab release view:*)"
    "Bash(glab label list:*)"
    "Bash(glab variable list:*)"
    "Bash(glab config get:*)"

    # Atlassian CLI, read-only operations
    "Bash(acli auth status:*)"
    "Bash(acli jira workitem view:*)"
    "Bash(acli jira workitem search:*)"
    "Bash(acli jira workitem comment list:*)"
    "Bash(acli jira workitem comment visibility:*)"
    "Bash(acli jira workitem attachment list:*)"
    "Bash(acli jira workitem link list:*)"
    "Bash(acli jira workitem link type:*)"
    "Bash(acli jira workitem watcher list:*)"
    "Bash(acli jira board search:*)"
    "Bash(acli jira board get:*)"
    "Bash(acli jira board list-projects:*)"
    "Bash(acli jira board list-sprints:*)"
    "Bash(acli jira sprint view:*)"
    "Bash(acli jira sprint list-workitems:*)"
    "Bash(acli jira project list:*)"
    "Bash(acli jira project view:*)"
    "Bash(acli jira filter get:*)"
    "Bash(acli jira filter get-columns:*)"
    "Bash(acli jira filter list:*)"
    "Bash(acli jira filter search:*)"
    "Bash(acli jira dashboard search:*)"
    "Bash(acli confluence page view:*)"
    "Bash(acli confluence space list:*)"
    "Bash(acli confluence space view:*)"
    "Bash(acli confluence blog list:*)"
    "Bash(acli confluence blog view:*)"
    "Bash(acli config:*)"

    # ITP skills
    "Skill(itp-engineering-daikin:*)"
    "Skill(itp-engineering-backend:*)"
    "Skill(itp-engineering:*)"
    "Skill(itp-general:*)"

    # Context7 MCP
    "mcp__context7__resolve-library-id"
    "mcp__context7__query-docs"

    # Quill MCP, read-only
    "mcp__quill__get_contact"
    "mcp__quill__get_event"
    "mcp__quill__get_meeting"
    "mcp__quill__get_meeting_type"
    "mcp__quill__get_minutes"
    "mcp__quill__get_note"
    "mcp__quill__get_template"
    "mcp__quill__get_thread"
    "mcp__quill__get_thread_note"
    "mcp__quill__get_transcript"
    "mcp__quill__list_contacts"
    "mcp__quill__list_events"
    "mcp__quill__list_meeting_types"
    "mcp__quill__list_notes"
    "mcp__quill__list_templates"
    "mcp__quill__list_thread_notes"
    "mcp__quill__list_threads"
    "mcp__quill__search_contacts"
    "mcp__quill__search_meetings"
    "mcp__quill__search_minutes"

    # Datadog MCP, read/search operations (both plugin name variants)
    "mcp__plugin_itp-engineering-daikin_datadog__aggregate_events"
    "mcp__plugin_itp-engineering-daikin_datadog__aggregate_rum_events"
    "mcp__plugin_itp-engineering-daikin_datadog__aggregate_spans"
    "mcp__plugin_itp-engineering-daikin_datadog__analyze_datadog_logs"
    "mcp__plugin_itp-engineering-daikin_datadog__check_datadog_mcp_setup"
    "mcp__plugin_itp-engineering-daikin_datadog__get_datadog_incident"
    "mcp__plugin_itp-engineering-daikin_datadog__get_datadog_metric"
    "mcp__plugin_itp-engineering-daikin_datadog__get_datadog_metric_context"
    "mcp__plugin_itp-engineering-daikin_datadog__get_datadog_notebook"
    "mcp__plugin_itp-engineering-daikin_datadog__get_datadog_trace"
    "mcp__plugin_itp-engineering-daikin_datadog__search_datadog_dashboards"
    "mcp__plugin_itp-engineering-daikin_datadog__search_datadog_events"
    "mcp__plugin_itp-engineering-daikin_datadog__search_datadog_hosts"
    "mcp__plugin_itp-engineering-daikin_datadog__search_datadog_incidents"
    "mcp__plugin_itp-engineering-daikin_datadog__search_datadog_logs"
    "mcp__plugin_itp-engineering-daikin_datadog__search_datadog_metrics"
    "mcp__plugin_itp-engineering-daikin_datadog__search_datadog_monitors"
    "mcp__plugin_itp-engineering-daikin_datadog__search_datadog_notebooks"
    "mcp__plugin_itp-engineering-daikin_datadog__search_datadog_rum_events"
    "mcp__plugin_itp-engineering-daikin_datadog__search_datadog_service_dependencies"
    "mcp__plugin_itp-engineering-daikin_datadog__search_datadog_services"
    "mcp__plugin_itp-engineering-daikin_datadog__search_datadog_spans"
    "mcp__plugin_daikin_datadog__aggregate_events"
    "mcp__plugin_daikin_datadog__aggregate_rum_events"
    "mcp__plugin_daikin_datadog__aggregate_spans"
    "mcp__plugin_daikin_datadog__analyze_datadog_logs"
    "mcp__plugin_daikin_datadog__check_datadog_mcp_setup"
    "mcp__plugin_daikin_datadog__get_datadog_incident"
    "mcp__plugin_daikin_datadog__get_datadog_metric"
    "mcp__plugin_daikin_datadog__get_datadog_metric_context"
    "mcp__plugin_daikin_datadog__get_datadog_notebook"
    "mcp__plugin_daikin_datadog__get_datadog_trace"
    "mcp__plugin_daikin_datadog__search_datadog_dashboards"
    "mcp__plugin_daikin_datadog__search_datadog_events"
    "mcp__plugin_daikin_datadog__search_datadog_hosts"
    "mcp__plugin_daikin_datadog__search_datadog_incidents"
    "mcp__plugin_daikin_datadog__search_datadog_logs"
    "mcp__plugin_daikin_datadog__search_datadog_metrics"
    "mcp__plugin_daikin_datadog__search_datadog_monitors"
    "mcp__plugin_daikin_datadog__search_datadog_notebooks"
    "mcp__plugin_daikin_datadog__search_datadog_rum_events"
    "mcp__plugin_daikin_datadog__search_datadog_service_dependencies"
    "mcp__plugin_daikin_datadog__search_datadog_services"
    "mcp__plugin_daikin_datadog__search_datadog_spans"

    # Incident.io MCP, read/query operations
    "mcp__plugin_itp-engineering-daikin_incidentio__alert_list"
    "mcp__plugin_itp-engineering-daikin_incidentio__alert_show"
    "mcp__plugin_itp-engineering-daikin_incidentio__alert_source_list"
    "mcp__plugin_itp-engineering-daikin_incidentio__alert_stats"
    "mcp__plugin_itp-engineering-daikin_incidentio__analysis_start"
    "mcp__plugin_itp-engineering-daikin_incidentio__ask"
    "mcp__plugin_itp-engineering-daikin_incidentio__ask_incident"
    "mcp__plugin_itp-engineering-daikin_incidentio__ask_telemetry"
    "mcp__plugin_itp-engineering-daikin_incidentio__catalog_entry_list"
    "mcp__plugin_itp-engineering-daikin_incidentio__catalog_entry_show"
    "mcp__plugin_itp-engineering-daikin_incidentio__catalog_type_list"
    "mcp__plugin_itp-engineering-daikin_incidentio__escalation_list"
    "mcp__plugin_itp-engineering-daikin_incidentio__escalation_path_list"
    "mcp__plugin_itp-engineering-daikin_incidentio__escalation_path_show"
    "mcp__plugin_itp-engineering-daikin_incidentio__escalation_show"
    "mcp__plugin_itp-engineering-daikin_incidentio__escalation_stats"
    "mcp__plugin_itp-engineering-daikin_incidentio__follow_up_list"
    "mcp__plugin_itp-engineering-daikin_incidentio__follow_up_stats"
    "mcp__plugin_itp-engineering-daikin_incidentio__incident_list"
    "mcp__plugin_itp-engineering-daikin_incidentio__incident_show"
    "mcp__plugin_itp-engineering-daikin_incidentio__incident_stats"
    "mcp__plugin_itp-engineering-daikin_incidentio__incident_update_list"
    "mcp__plugin_itp-engineering-daikin_incidentio__resource_list"
    "mcp__plugin_itp-engineering-daikin_incidentio__resource_show"
    "mcp__plugin_itp-engineering-daikin_incidentio__schedule_list"
    "mcp__plugin_itp-engineering-daikin_incidentio__schedule_show"
    "mcp__plugin_itp-engineering-daikin_incidentio__team_list"
    "mcp__plugin_itp-engineering-daikin_incidentio__team_show"

    # Gmail MCP, read-only
    "mcp__claude_ai_Gmail__gmail_get_profile"
    "mcp__claude_ai_Gmail__gmail_list_drafts"
    "mcp__claude_ai_Gmail__gmail_list_labels"
    "mcp__claude_ai_Gmail__gmail_read_message"
    "mcp__claude_ai_Gmail__gmail_read_thread"
    "mcp__claude_ai_Gmail__gmail_search_messages"

    # Google Calendar MCP, read-only
    "mcp__claude_ai_Google_Calendar__gcal_get_event"
    "mcp__claude_ai_Google_Calendar__gcal_list_calendars"
    "mcp__claude_ai_Google_Calendar__gcal_list_events"
    "mcp__claude_ai_Google_Calendar__gcal_find_meeting_times"
    "mcp__claude_ai_Google_Calendar__gcal_find_my_free_time"

    # Slack MCP, read/search operations
    "mcp__claude_ai_Slack__slack_read_channel"
    "mcp__claude_ai_Slack__slack_read_thread"
    "mcp__claude_ai_Slack__slack_read_user_profile"
    "mcp__claude_ai_Slack__slack_read_canvas"
    "mcp__claude_ai_Slack__slack_search_channels"
    "mcp__claude_ai_Slack__slack_search_public"
    "mcp__claude_ai_Slack__slack_search_public_and_private"
    "mcp__claude_ai_Slack__slack_search_users"

    # Figma MCP, read-only
    "mcp__claude_ai_Figma__get_code_connect_map"
    "mcp__claude_ai_Figma__get_code_connect_suggestions"
    "mcp__claude_ai_Figma__get_context_for_code_connect"
    "mcp__claude_ai_Figma__get_design_context"
    "mcp__claude_ai_Figma__get_figjam"
    "mcp__claude_ai_Figma__get_metadata"
    "mcp__claude_ai_Figma__get_screenshot"
    "mcp__claude_ai_Figma__get_variable_defs"
    "mcp__claude_ai_Figma__search_design_system"
    "mcp__claude_ai_Figma__whoami"

    # Tally MCP, read-only
    "mcp__claude_ai_Tally__fetch_insights"
    "mcp__claude_ai_Tally__fetch_submissions"
    "mcp__claude_ai_Tally__list_blocks"
    "mcp__claude_ai_Tally__list_forms"
    "mcp__claude_ai_Tally__list_workspaces"
    "mcp__claude_ai_Tally__load_form"

    # Web access
    "WebFetch(*)"
    "WebFetch(domain:*)"
    "WebSearch"
  ];

  # Autonomous profile additions
  autonomousAllow = standardAllow ++ [
    "Bash(git checkout:*)"
    "Bash(git switch:*)"
    "Bash(git stash:*)"
    "Bash(git restore:*)"
  ];

  # Operations requiring confirmation in non-autonomous mode
  standardAsk = [
    # Potentially destructive git commands
    "Bash(git checkout:*)"
    "Bash(git merge:*)"
    "Bash(git pull:*)"
    "Bash(git push:*)"
    "Bash(git rebase:*)"
    "Bash(git reset:*)"
    "Bash(git restore:*)"
    "Bash(git stash:*)"
    "Bash(git switch:*)"

    # File deletion and modification
    "Bash(cp:*)"
    "Bash(mv:*)"
    "Bash(rm:*)"

    # Nix commands that can execute arbitrary code
    "Bash(nix shell:*)"
    "Bash(nix develop:*)"
    "Bash(nix run:*)"
    "Bash(nix-shell:*)"
    "Bash(nix-build:*)"
    "Bash(darwin-rebuild:*)"

    # GitHub CLI, mutating operations
    "Bash(gh issue create:*)"
    "Bash(gh issue close:*)"
    "Bash(gh issue reopen:*)"
    "Bash(gh issue edit:*)"
    "Bash(gh issue delete:*)"
    "Bash(gh issue comment:*)"
    "Bash(gh pr create:*)"
    "Bash(gh pr merge:*)"
    "Bash(gh pr close:*)"
    "Bash(gh pr reopen:*)"
    "Bash(gh pr edit:*)"
    "Bash(gh pr review:*)"
    "Bash(gh pr comment:*)"
    "Bash(gh release create:*)"
    "Bash(gh release delete:*)"
    "Bash(gh repo create:*)"
    "Bash(gh repo delete:*)"
    "Bash(gh repo fork:*)"
    "Bash(gh run rerun:*)"
    "Bash(gh run cancel:*)"

    # GitLab CLI, mutating operations
    "Bash(glab mr create:*)"
    "Bash(glab mr merge:*)"
    "Bash(glab mr close:*)"
    "Bash(glab mr reopen:*)"
    "Bash(glab mr update:*)"
    "Bash(glab mr approve:*)"
    "Bash(glab mr revoke:*)"
    "Bash(glab mr note:*)"
    "Bash(glab mr delete:*)"
    "Bash(glab mr for:*)"
    "Bash(glab mr rebase:*)"
    "Bash(glab mr subscribe:*)"
    "Bash(glab mr unsubscribe:*)"
    "Bash(glab mr todo:*)"
    "Bash(glab issue create:*)"
    "Bash(glab issue close:*)"
    "Bash(glab issue reopen:*)"
    "Bash(glab issue update:*)"
    "Bash(glab issue delete:*)"
    "Bash(glab issue note:*)"
    "Bash(glab issue subscribe:*)"
    "Bash(glab issue unsubscribe:*)"
    "Bash(glab ci run:*)"
    "Bash(glab ci run-trig:*)"
    "Bash(glab ci trigger:*)"
    "Bash(glab ci cancel:*)"
    "Bash(glab ci delete:*)"
    "Bash(glab ci retry:*)"
    "Bash(glab pipeline run:*)"
    "Bash(glab pipeline delete:*)"
    "Bash(glab repo create:*)"
    "Bash(glab repo delete:*)"
    "Bash(glab repo fork:*)"
    "Bash(glab repo mirror:*)"
    "Bash(glab repo transfer:*)"
    "Bash(glab repo update:*)"
    "Bash(glab release create:*)"
    "Bash(glab config set:*)"

    # Atlassian CLI, mutating operations
    "Bash(acli jira workitem create:*)"
    "Bash(acli jira workitem create-bulk:*)"
    "Bash(acli jira workitem edit:*)"
    "Bash(acli jira workitem delete:*)"
    "Bash(acli jira workitem assign:*)"
    "Bash(acli jira workitem transition:*)"
    "Bash(acli jira workitem archive:*)"
    "Bash(acli jira workitem unarchive:*)"
    "Bash(acli jira workitem clone:*)"
    "Bash(acli jira workitem comment create:*)"
    "Bash(acli jira workitem comment update:*)"
    "Bash(acli jira workitem comment delete:*)"
    "Bash(acli jira workitem attachment delete:*)"
    "Bash(acli jira workitem link create:*)"
    "Bash(acli jira workitem link delete:*)"
    "Bash(acli jira workitem watcher remove:*)"
    "Bash(acli jira board create:*)"
    "Bash(acli jira board delete:*)"
    "Bash(acli jira sprint create:*)"
    "Bash(acli jira sprint update:*)"
    "Bash(acli jira sprint delete:*)"
    "Bash(acli jira project create:*)"
    "Bash(acli jira project update:*)"
    "Bash(acli jira project delete:*)"
    "Bash(acli jira project archive:*)"
    "Bash(acli jira project restore:*)"
    "Bash(acli confluence space create:*)"
    "Bash(acli confluence space update:*)"
    "Bash(acli confluence space archive:*)"
    "Bash(acli confluence space restore:*)"
    "Bash(acli confluence blog create:*)"

    # AWS vault
    "Bash(aws-vault:*)"

    # Terraform mutations
    "Bash(terraform apply:*)"
    "Bash(terraform destroy:*)"
    "Bash(terraform import:*)"

    # Datadog MCP, mutating operations
    "mcp__plugin_itp-engineering-daikin_datadog__create_datadog_notebook"
    "mcp__plugin_itp-engineering-daikin_datadog__edit_datadog_notebook"
    "mcp__plugin_daikin_datadog__create_datadog_notebook"
    "mcp__plugin_daikin_datadog__edit_datadog_notebook"

    # Incident.io MCP, mutating operations
    "mcp__plugin_itp-engineering-daikin_incidentio__escalation_respond"
    "mcp__plugin_itp-engineering-daikin_incidentio__feedback"
    "mcp__plugin_itp-engineering-daikin_incidentio__follow_up_create"
    "mcp__plugin_itp-engineering-daikin_incidentio__follow_up_update"
    "mcp__plugin_itp-engineering-daikin_incidentio__incident_create"
    "mcp__plugin_itp-engineering-daikin_incidentio__incident_update"
    "mcp__plugin_itp-engineering-daikin_incidentio__investigation_steer"
    "mcp__plugin_itp-engineering-daikin_incidentio__investigation_sync"

    # Quill MCP, mutating operations
    "mcp__quill__add_contact_observation"
    "mcp__quill__add_meetings_to_thread"
    "mcp__quill__add_to_dictionary"
    "mcp__quill__create_contact"
    "mcp__quill__create_meeting_type"
    "mcp__quill__create_note"
    "mcp__quill__create_template"
    "mcp__quill__create_thread"
    "mcp__quill__create_thread_note"
    "mcp__quill__update_contact"
    "mcp__quill__update_event"
    "mcp__quill__update_meeting_type"
    "mcp__quill__update_note"
    "mcp__quill__update_template"

    # Gmail MCP, mutating operations
    "mcp__claude_ai_Gmail__gmail_create_draft"

    # Google Calendar MCP, mutating operations
    "mcp__claude_ai_Google_Calendar__gcal_create_event"
    "mcp__claude_ai_Google_Calendar__gcal_delete_event"
    "mcp__claude_ai_Google_Calendar__gcal_update_event"
    "mcp__claude_ai_Google_Calendar__gcal_respond_to_event"

    # Slack MCP, mutating operations
    "mcp__claude_ai_Slack__slack_create_canvas"
    "mcp__claude_ai_Slack__slack_schedule_message"
    "mcp__claude_ai_Slack__slack_send_message"
    "mcp__claude_ai_Slack__slack_send_message_draft"
    "mcp__claude_ai_Slack__slack_update_canvas"

    # Figma MCP, mutating operations
    "mcp__claude_ai_Figma__add_code_connect_map"
    "mcp__claude_ai_Figma__create_design_system_rules"
    "mcp__claude_ai_Figma__create_new_file"
    "mcp__claude_ai_Figma__generate_diagram"
    "mcp__claude_ai_Figma__send_code_connect_mappings"
    "mcp__claude_ai_Figma__use_figma"

    # Tally MCP, mutating operations
    "mcp__claude_ai_Tally__apply_logic"
    "mcp__claude_ai_Tally__configure_blocks"
    "mcp__claude_ai_Tally__create_blocks"
    "mcp__claude_ai_Tally__create_new_form"
    "mcp__claude_ai_Tally__move_blocks"
    "mcp__claude_ai_Tally__remove_blocks"
    "mcp__claude_ai_Tally__remove_pages"
    "mcp__claude_ai_Tally__remove_questions"
    "mcp__claude_ai_Tally__reposition_pages"
    "mcp__claude_ai_Tally__reposition_questions"
    "mcp__claude_ai_Tally__save_form"
    "mcp__claude_ai_Tally__set_column_layout"
    "mcp__claude_ai_Tally__set_form_title"
    "mcp__claude_ai_Tally__update_settings"
    "mcp__claude_ai_Tally__update_text"

    # Network operations
    "Bash(curl:*)"
    "Bash(ping:*)"
    "Bash(rsync:*)"
    "Bash(scp:*)"
    "Bash(ssh:*)"
    "Bash(wget:*)"

    # System operations
    "Bash(sudo:*)"

    # Process management
    "Bash(kill:*)"
    "Bash(killall:*)"
    "Bash(pkill:*)"
  ];

  # Autonomous mode still requires confirmation for these
  autonomousAsk = [
    "Bash(git push:*)"
    "Bash(git merge:*)"
    "Bash(git rebase:*)"
    "Bash(git reset:*)"
    "Bash(rm:*)"
    "Bash(darwin-rebuild:*)"
    "Bash(sudo:*)"
    "Bash(curl:*)"
    "Bash(rsync:*)"
    "Bash(scp:*)"
    "Bash(ssh:*)"
    "Bash(wget:*)"
    "Bash(kill:*)"
    "Bash(killall:*)"
    "Bash(pkill:*)"
  ];

  # Never allowed
  denyList = [
    "Bash(rm -rf /*)"
    "Bash(rm -rf /)"
    "Bash(dd:*)"
    "Bash(mkfs:*)"
    "Read(.env)"
    "Read(.env.*)"
    "Bash(cat .env*)"
    "Bash(printenv:*)"
  ];
in
{
  options.programs.claude-code.permissionProfile = lib.mkOption {
    type = lib.types.enum [
      "conservative"
      "standard"
      "autonomous"
    ];
    default = "standard";
    description = ''
      Permission profile for Claude Code operations:
      - conservative: Minimal permissions, most operations require confirmation
      - standard: Balanced permissions for normal development workflows
      - autonomous: Maximum autonomy for trusted environments
    '';
  };

  config = lib.mkIf cfg.enable {
    programs.claude-code.settings.permissions = {
      allow =
        if cfg.permissionProfile == "autonomous" then
          autonomousAllow
        else if cfg.permissionProfile == "standard" then
          standardAllow
        else
          baseAllow;

      ask =
        if cfg.permissionProfile == "autonomous" then
          autonomousAsk
        else if cfg.permissionProfile == "standard" then
          standardAsk
        else
          standardAsk ++ standardAllow;

      deny = denyList;
    };
  };
}
