require 'octokit'
require 'git'
require 'net/http'
require 'uri'

module HS
  module Command extend self

    include HS::CommandHelpers

    def generate_action_proc(command)
      require "hs/commands/#{command.name}"
      Proc.new do |global_opts, opts, args|
        init(global_opts, opts, args)
        send(command.name)
      end
    end

    def init(global_opts, opts, args)
      @global_opts = global_opts
      @opts = opts
      @args = args

      @hs = HS::CodeReviewClient.new(HS::Authentication.api_secret)
      if File.exists?(File.expand_path(File.join("~", ".netrc")))
        ::Octokit.netrc = true
      end
      @gh = ::Octokit.new
    end

    def require_message(initial_value='')
      @opts[:message] ||= prompt_message(initial_value)
    end

    def prompt_message(initial_value)
      input = editor_input(initial_value)
        .split("\n").reject { |l| l.start_with? "#" }.join("\n")

      if input.empty?
        $stderr.puts "Empty message. Aborting."
        exit(1)
      else
        input
      end
    end

    def github_url_data(url)
      uri = URI(url)
      if uri.host =~ /github/
        _, username, repo = uri.path.split('/')
        {:url => uri.to_s, :username => username, :repo => repo}
      else
        # XXX: This should raise an exception instead, methinks
        $stderr.puts "Remotes must be github.com"
        exit(1)
      end
    end

    def remote_data(git, remote)
      github_url_data(git.remote(remote).url.chomp('.git'))
    end
  end

  class CommandError < StandardError; end
end
