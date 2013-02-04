require 'spec_helper'

describe HS::CodeReviewClient do
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
    it "requires a :body and :repo" do
      [{}, {:body => true}, {:repo => true}].each do |data|
        expect { @client.request(data) }.to raise_error(HS::APIError)
      end

      @client.request(:body => true, :repo => true).code.should eq("200")
    end
  end

  describe "#respond" do
    it "requires a :url, :repo, and :base_repo" do
      [{}, {:url => true}, {:url => true, :repo => true}].each do |data|
        expect { @client.respond(data) }.to raise_error(HS::APIError)
      end

      @client.respond(:url => true, :repo => true, :base_repo => true).code.
        should eq("200")
    end
  end
end
