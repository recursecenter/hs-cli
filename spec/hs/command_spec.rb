require 'spec_helper'

describe HS::Command do
  describe "::github_url_data" do
    urls = ["http://github.com/username/repo",
            "https://github.com/username/repo",
            "http://github.com/username/repo/extra",
            "http://www.github.com/username/repo"]

    urls.each do |url|
      it "extracts username and repo from '#{url}'" do
        parsed = HS::Command.send(:github_url_data, url)
        parsed[:username].should eq('username')
        parsed[:repo].should eq('repo')
      end
    end
  end
end
