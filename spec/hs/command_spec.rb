require 'spec_helper'

describe HS::Command do
  describe "#extract_username_from_url" do
    cmd = HS::Command.new(true, true, true)
    urls = ["http://github.com/username",
             "https://github.com/username",
             "http://github.com/username/foobar",
             "http://www.github.com/username"]

    urls.each do |url|
      it "extracts 'username' from '#{url}'" do
        cmd.send(:extract_username_from_url, url).should eq("username")
      end
    end
  end

  describe "#parse_review_args" do
    data = {
      ["username/repo", "folder"] => {
        :username => "username",
        :repo => "repo",
        :branch => "master",
        :name => "folder"
      },
      ["username/repo:branch", "folder"] => {
        :username => "username",
        :repo => "repo",
        :branch => "branch",
        :name => "folder"
      },
      ["username/repo"] => {
        :username => "username",
        :repo => "repo",
        :branch => "master",
        :name => "repo"
      }
    }

    data.each do |args, out|
      it "parses #{args} correctly" do
        HS::Command.new(true, true, args).send(:parse_review_args).
          should eq(out)
      end
    end

    it "requires 'username/repo'" do
      expect {
        HS::Command.new(true, true, ["username:branch"]).send(:parse_review_args)
      }.to raise_error(HS::CommandError)
    end
  end
end
