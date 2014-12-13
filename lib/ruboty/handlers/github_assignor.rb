require 'json'

module Ruboty
  module Handlers
    class GithubAssignor < Base
      env :GITHUB_ASSIGNOR_REPOS, "e.g. '#{[{repo: 'your/repo', to: 'chatroom', assignees: [{chat_name: 'name', github_name: 'name'}]}].to_json}'"
      env :GITHUB_TOKEN, "GitHub Access Token"
      env :GITHUB_ASSIGNOR_INTERVAL, "Check interval", optional: true

      def initialize(*args)
        super

        start_watching
      end

      private

      def start_watching
        octokit = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])

        data = JSON.parse(ENV['GITHUB_ASSIGNOR_REPOS'])
        Ruboty::GithubAssignor.log(data)

        data.each do |datum|
          repo = datum['repo']
          to = datum['to']
          assignees = Hash[datum['assignees'].map {|k, v| [k.to_sym, v] }]
          assignor = Ruboty::GithubAssignor::Assignor.new(assignees)

          watcher = Ruboty::GithubAssignor::RepoWatcher.new(
            robot: robot,
            repo: repo,
            octokit: octokit,
            assignor: assignor,
            to: to,
          )
          watcher.start((ENV['GITHUB_ASSIGNOR_INTERVAL'] || 60).to_i)
        end
      end
    end
  end
end
