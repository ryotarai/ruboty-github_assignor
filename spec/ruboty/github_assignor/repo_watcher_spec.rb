require 'spec_helper'

describe Ruboty::GithubAssignor::RepoWatcher do
  let(:robot) { Ruboty::Robot.new }
  let(:octokit) { Octokit::Client.new(access_token: 'access_token') }
  let(:assignor) do
    Ruboty::GithubAssignor::Assignor.new([
      {chat_name: 'alice', github_name: 'gh_alice'},
      {chat_name: 'bob', github_name: 'gh_bob'},
    ]).tap {|assignor| assignor.current = 0 }
  end

  subject(:watcher) do
    described_class.new(
      robot: robot,
      repo: 'octocat/Hello-World',
      octokit: octokit,
      assignor: assignor,
      to: 'room',
    )
  end

  let(:request_header) { {'Accept'=>'application/vnd.github.v3+json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'token access_token', 'Content-Type'=>'application/json', 'User-Agent'=>'Octokit Ruby Gem 3.7.0'} }

  describe '#check_issues' do
    before do
      stub_request(:get, "https://api.github.com/repos/octocat/Hello-World/issues").
        with(:headers => request_header).
        to_return(:status => 200, :body => fixture('issues1.json'), :headers => {'Content-Type' => 'application/json; charset=utf-8'}).then.
        to_return(:status => 200, :body => fixture('issues2.json'), :headers => {'Content-Type' => 'application/json; charset=utf-8'})
    end

    it 'sends a message to assignee' do
      stub_request(:patch, "https://api.github.com/repos/octocat/Hello-World/issues/1347").
        with(:body => "{\"assignee\":\"gh_alice\"}",
             :headers => request_header).
        to_return(:status => 200, :body => "", :headers => {})

      expect(robot).to receive(:say).with(
        hash_including(body: <<-EOC)
@alice さん、お願いします！

Found a bug
<https://github.com/octocat/Hello-World/issues/1347>
        EOC
      )
      watcher.check_issues
    end
  end
end

