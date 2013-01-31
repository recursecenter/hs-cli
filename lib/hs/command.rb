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
      ::Octokit.netrc = true
      @gh = ::Octokit.new
    end

    def request
      require_message("\n# Review request description")
      puts "requesting #{@opts}"
    end

    def review
      puts "reviewing #{@opts}"
    end

    def submit
      require_message("\n# Pull request description")
      puts "submitting #{@opts}"
    end

    private

    def require_message(initial_value)
      @opts[:message] ||= CommandHelpers.editor_input(initial_value)
    end
  end

  class CommandError < Exception
  end
end
