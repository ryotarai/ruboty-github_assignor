module Ruboty
  module GithubAssignor
    class Assignee < Struct.new(:chat_name, :github_name)
    end

    class Assignor
      attr_accessor :current

      def initialize(assignees)
        @assignees = assignees.map do |assignee|
          Assignee.new(*assignee.values_at(*Assignee.members))
        end
        @current = rand(@assignees.size)
      end

      def next
        assignee = @assignees[@current % @assignees.size]
        @current += 1

        assignee
      end
    end
  end
end
