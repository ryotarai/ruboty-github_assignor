require 'octokit'

module Ruboty
  module GithubAssignor
    class RepoWatcher
      def initialize(robot:, repo:, octokit:, assignor:, to:)
        @robot = robot
        @repo = repo
        @octokit = octokit
        @assignor = assignor
        @to = to

        @checked_issue_ids = []

        check_issues(false)
      end

      def check_issues(assign = true)
        @octokit.issues(@repo).each do |issue|
          unless @checked_issue_ids.include?(issue[:id])
            log "New issue found (#{issue[:id]} / #{issue[:title]})"
            if assign && !issue[:assignee]
              # assign this issue
              assignee = @assignor.next
              log "Assign this issue to #{assignee}"

              @octokit.update_issue(@repo, issue[:number], assignee: assignee.github_name)
              say(<<-EOC)
@#{assignee.chat_name} さん、お願いします！

#{issue[:title]}
<#{issue[:html_url]}>
              EOC
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
            check_issues
          end
        end
      end

      private

      def say(body)
        from = if @robot.send(:adapter).respond_to?(:jid, true)
                 @robot.send(:adapter).send(:jid)
               else
                 nil
               end

        @robot.say(
          body: body,
          from: from,
          to: @to,
          original: {type: "groupchat"},
        )
      end

      def log(msg)
        Ruboty.logger.info "[github_assignor][#{@repo}] #{msg}"
      end
    end
  end
end

