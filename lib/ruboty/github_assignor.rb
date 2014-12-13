require 'ruboty'
require "ruboty/github_assignor/version"
require "ruboty/github_assignor/repo_watcher"
require "ruboty/github_assignor/assignor"
require "ruboty/handlers/github_assignor"

module Ruboty
  module GithubAssignor
    # Your code goes here...

    def self.log(msg)
      Ruboty.logger.info "[github_assignor] #{msg}"

      # FIX thix dirty hack.
      Ruboty.logger.instance_variable_get(:@logdev).dev.flush
    end
  end
end
