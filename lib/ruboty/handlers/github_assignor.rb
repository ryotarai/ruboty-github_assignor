module Ruboty
  module Handlers
    class GithubAssignor < Base
      on(
        /tell me github_assignor version/,
        name: 'show_version',
        description: 'Show version of github_assignor plugin',
      )

      def show_version(message)
        message.reply(Ruboty::GithubAssignor::VERSION)
      end
    end
  end
end
