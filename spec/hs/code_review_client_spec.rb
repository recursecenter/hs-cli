require 'spec_helper'

describe HS::CodeReviewClient do
  include Helpers

  before(:each) do
    @secret = "secret"
    @client = HS::CodeReviewClient.new(@secret)

    stub_request(:any, /.*(localhost)|(hackerschool).*/)
  end

  describe "#initialize" do
    it "has default_data" do
      @client.instance_variable_get("@default_data").should eq({:api_secret => @secret})
    end
  end

  describe "#request" do
    data = [{}, {:body => true}, {:repo => true}]

    data.each do |args|
      it "errors on insufficient args (#{args})" do
        expect { @client.request(args) }.to raise_error(HS::APIError)
      end
    end

    it "POSTs with sufficient symbol args" do
      data = hash_with_keys [:body, :repo, :github_account]
      @client.request(data).code.should eq('200')
    end

    it "POSTs with sufficient string args" do
      data = hash_with_keys ['body', 'repo', 'github_account']
      @client.request(data).code.should eq('200')
    end
  end

  describe "#respond" do
    data = [{}, {:url => true}, {:url => true, :repo => true}]

    data.each do |args|
      it "errors on insufficient args (#{args})" do
        expect { @client.respond(args) }.to raise_error(HS::APIError)
      end
    end

    context "POSTs with sufficient args" do
      data = [:url, :repo, :base_repo, :base_github]

      it "that are symbols" do
        @client.respond(hash_with_keys(data)).code.should eq('200')
      end

      it "that are strings" do
        @client.respond(hash_with_keys(data.map(&:to_s))).code.should eq('200')
      end
    end
  end
end
