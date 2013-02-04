require 'spec_helper'

describe HS::Authentication do
  include HS::Authentication

  describe '::gets_non_empty' do
    it "shouldn't return newlines" do
      $stdin.should_receive(:gets).and_return("foo\n")
      gets_non_empty('').should eq("foo")
    end

    it "shouldn't return empty strings" do
      $stdin.should_receive(:gets).and_return("", "foo")
      gets_non_empty('').should eq("foo")
    end
  end

  describe '::request_github_creds' do
    it 'should return a [user,pass] array' do
      $stdin.should_receive(:gets).and_return("user", "pass")
      request_github_creds.should eq(["user", "pass"])
    end
  end
end
