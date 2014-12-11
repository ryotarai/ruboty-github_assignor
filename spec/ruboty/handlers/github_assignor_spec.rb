require 'spec_helper'

describe Ruboty::Handlers::GithubAssignor do
  let(:robot) { Ruboty::Robot.new }

  let(:sender) { 'Alice' }
  let(:channel) { '#wonderland' }

  describe '#show_version' do
    let(:body) { 'ruboty tell me github_assignor version' }
    it 'replies version number' do
      expect(robot).to receive(:say).with(
        hash_including(body: Ruboty::GithubAssignor::VERSION)
      )
      robot.receive(body: body, from: sender, to: channel)
    end
  end
end

