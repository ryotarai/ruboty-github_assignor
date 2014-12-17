require 'octokit'

module Ruboty
  module GithubAssignor
    class RepoWatcher
      def initialize(robot:, repo:, octokit:, assignor:, to:, messages:)
        @robot = robot
        @repo = repo
        @octokit = octokit
        @assignor = assignor
        @to = to
        @messages = messages

        @checked_issue_ids = []

        check_issues(false)
      end

      def check_issues(assign = true)
        log "Checking new issues..."

        @octokit.issues(@repo).each do |issue|
          unless @checked_issue_ids.include?(issue[:id])
            log "New issue found (#{issue[:id]} / #{issue[:title]})"
            message = find_message(issue)
            if message && assign && !issue[:assignee]
              # assign this issue
              assignee = @assignor.next
              log "Assigning this issue to #{assignee}..."

              log "Updating assignee of GitHub issue..."
              @octokit.update_issue(@repo, issue[:number], assignee: assignee.github_name)

              log "Reminding the user of the issue..."
              say(<<-EOC)
@#{assignee.chat_name} さん、#{message['message']}お願いします！

#{issue[:title]}
<#{issue[:html_url]}>
              EOC

              log "Done."
            end
            @checked_issue_ids << issue[:id]
          end
        end
      end

      def start(interval)
        Thread.start do
          log "Start watching issues"
          loop do
            sleep(interval)
            begin
              check_issues
            rescue => err
              log err.inspect
            end
          end
        end
      end

      private

      # messages
      # [
      #   {
      #     "message": "レビュー",
      #     "conditions": [{
      #       "keywords": [...], # AND
      #       "including_mention": true/false,
      #     }],
      #   }
      # ]
      def find_message(issue)
        including_mention = (/(^| )@\w+/ =~ issue[:body])

        @messages.find do |message|
          message['conditions'].any? do |condition|
            if condition.has_key?('including_mention') &&
              (condition['including_mention'] && !including_mention ||
               !condition['including_mention'] && including_mention)
              next false
            end

            including_all_keywords = condition['keywords'].all? do |keyword|
              issue[:body].downcase.include?(keyword.downcase)
            end

            including_all_keywords
          end
        end
      end

      def say(body)
        from = if @robot.send(:adapter).respond_to?(:jid, true)
                 @robot.send(:adapter).send(:jid)
               else
                 nil
               end

        log "#{@from} -> #{@to}"
        @robot.say(
          body: body,
          from: from,
          to: @to,
          original: {type: "groupchat"},
        )
      end

      def log(msg)
        GithubAssignor.log("[#{@repo}] #{msg}")
      end
    end
  end
end

