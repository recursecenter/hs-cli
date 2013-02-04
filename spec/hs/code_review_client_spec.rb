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
    data = [{}, {:body => true}, {:repo => true}]

    data.each do |args|
      it "errors on insufficient args (#{args})" do
        expect { @client.request(args) }.to raise_error(HS::APIError)
      end
    end

    it "POSTs with sufficient args" do
      @client.request(:body => true, :repo => true).code.should eq("200")
    end
  end

  describe "#respond" do
    data = [{}, {:url => true}, {:url => true, :repo => true}]

    data.each do |args|
      it "errors on insufficient args (#{args})" do
        expect { @client.respond(args) }.to raise_error(HS::APIError)
      end
    end

    it "POSTs with sufficient args" do
      @client.respond(:url => true, :repo => true, :base_repo => true).code.
        should eq("200")
    end
  end
end
