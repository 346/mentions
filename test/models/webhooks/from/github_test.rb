require 'test_helper'

class Webhooks::From::GithubTest < ActiveSupport::TestCase
  def test_comment
    %w(commit_comment
       issue_comment
       pull_request
       issues
       pull_request_review_comment).each do |event|

      payload = JSON.parse(YAML.load_file("#{Rails.root}/test/payloads/github_payloads.yml")[event]['body'])
      github = Webhooks::From::Github.new(payload: payload)

      assert_equal "#{event} body", github.comment
    end
  end
end