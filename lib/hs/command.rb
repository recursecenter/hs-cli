require 'octokit'

module HS

  class Command
    def self.dispatch(command)
      Proc.new do |global_opts, opts, args|
        self.new(global_opts, opts, args).execute(command.name)
      end
    end

    alias_method :execute, :send

    def initialize(global_opts, opts, args)
      @global_opts = global_opts
      @opts = opts
      @args = args
      @hs = HS::CodeReviewClient.new(HS::Authentication.api_secret)
      Octokit.netrc = true
      @gh = OctoKit.new
    end

    def request
      puts "requesting"
    end

    def review
      puts "reviewing"
    end

    def submit
      puts "submitting"
    end
  end

end
