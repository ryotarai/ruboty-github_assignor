require 'json'

module Ruboty
  module Handlers
    class GithubAssignor < Base
      env :GITHUB_ASSIGNOR_REPOS, "e.g. '#{[{repo: 'your/repo', to: 'chatroom', assignees: [{chat_name: 'name', github_name: 'name'}]}].to_json}'"
      env :GITHUB_TOKEN, "GitHub Access Token"
      env :GITHUB_ASSIGNOR_INTERVAL, "Check interval", optional: true

      on(
        /tell me github_assignor version/,
        name: 'show_version',
        description: 'Show version of github_assignor plugin',
      )

      def initialize(*args)
        super

        start_watching
      end

      def show_version(message)
        message.reply(Ruboty::GithubAssignor::VERSION)
      end

      private

      def start_watching
        octokit = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])

        data = JSON.parse(ENV['GITHUB_ASSIGNOR_REPOS'])
        data.each do |datum|
          repo = datum['repo']
          to = datum['to']
          assignor = Ruboty::GithubAssignor::Assignor.new(datum['assignees'])

          Ruboty::GithubAssignor::RepoWatcher.new(
            robot: robot,
            repo: repo,
            octokit: octokit,
            assignor: assignor,
            to: to,
          ).start((ENV['GITHUB_ASSIGNOR_INTERVAL'] || 60).to_i)
        end
      end
    end
  end
end
