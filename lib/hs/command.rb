require 'octokit'
require 'git'
require 'net/http'

module HS
  class Command
    def self.generate_action_proc(command)
      Proc.new do |global_opts, opts, args|
        self.new(global_opts, opts, args).send(command.name)
      end
    end

    def initialize(global_opts, opts, args)
      @global_opts = global_opts
      @opts = opts
      @args = args
      @hs = HS::CodeReviewClient.new(HS::Authentication.api_secret)

      if File.exists?(File.expand_path(File.join("~", ".netrc")))
        ::Octokit.netrc = true
      end
      @gh = ::Octokit.new
    end

    def request
      require_message("\n# Code review request description")

      origin_data = remote_data(::Git.init('.'), 'origin')
      resp = @hs.request(:body => @opts[:message],
                         :repo => origin_data[:repo],
                         :branch => @opts[:branch],
                         :github_account => origin_data[:username])

      # HTTPResponse#value raises an HTTPError if the status code is not 2xx
      begin resp.value
        puts "Hacker School code review requested for #{origin_data[:repo]}:#{@opts[:branch]}.\nPlease remember to push recent changes to GitHub!"
      rescue ::Net::HTTPError
        puts resp.body
      end
    end

    def review
      args = parse_review_args
      review_branch = "#{args[:branch]}-review"

      # sleep to give GH a chance to update refs
      # TODO: Clone from origin
      clone_url, source_url = gh_fork("#{args[:username]}/#{args[:repo]}")

      sleep(1)

      # TODO: make error message
      unless clone_url
        $stderr.puts "Error message"
        exit(1)
      end

      git_repo = clone_locally(clone_url, args[:name])

      unless git_repo
        $stderr.puts "Error message 2"
        exit(1)
      end

      git_repo.branch(review_branch).checkout
      git_repo.push(git_repo.remote('origin'), review_branch)
      git_repo.add_remote('upstream', source_url)
      @hs.respond(:url => "#{clone_url.chomp('.git')}/tree/#{review_branch}",
                  :repo => args[:repo],
                  :branch => review_branch,
                  :base_repo => args[:repo],
                  :base_branch => args[:branch],
                  :base_github => parse_github_url(source_url)[:username],
                  :completed => false)

      puts "A review branch (#{review_branch}) has been created in local repository #{args[:name]}.\nHappy reviewing!"
    end

    def submit
      require_message("\n# Pull request description")

      git_repo = Git.init('.')
      origin_data = remote_data(git_repo, 'origin')
      upstream_data = remote_data(git_repo, 'upstream')

      head = git_repo.current_branch
      base = head.chomp("-review")

      userhead = "#{upstream_data[:username]}:#{head}"
      upstream_repo = ::Octokit::Repository.from_url(upstream_data[:url])
      resp = @gh.create_pull_request(upstream_repo, base, userhead, "Code review", @opts[:message])

      pull_url = resp[:html_url]
      @hs.respond(:url => pull_url,
                  :repo => origin_data[:repo],
                  :branch => head,
                  :base_repo => upstream_data[:repo],
                  :base_branch => base,
                  :completed => true)

      puts "Code review pull request submitted."
    end

    private

    def require_message(initial_value='')
      @opts[:message] ||= prompt_message initial_value
    end

    def prompt_message(initial_value)
      input = CommandHelpers.editor_input(initial_value)
      input.split("\n").reject { |l| l.start_with? "#" }.join("\n")
    end

    def parse_review_args
      repo_arg, name = @args
      username, repo_branch = repo_arg.split('/')

      unless username && repo_branch
        raise CommandError, "Username and repo must be specified."
      end

      repo, branch = repo_branch.split(':')

      { :username => username,
        :repo => repo,
        :branch => branch || 'master',
        :name => name || repo }
    end

    def gh_fork(repo_string)
      puts "Forking..."
      resp = @gh.fork(repo_string)
      [resp[:clone_url], resp[:source][:clone_url]]
    end

    def clone_locally(url, name)
      puts "Cloning locally..."
      ::Git.clone(url, name)
    end

    # TODO: Use URI
    def parse_github_url(url)
      /.*github\.com\/(?<username>[^\/]*)\/(?<repo>[^\/]*)(\/.*)?/.match(url)
    end

    def remote_data(git_repo, remote)
      data = parse_github_url(git_repo.remote(remote).url.chomp('.git'))
      {:url => data[0], :username => data[:username], :repo => data[:repo]}
    end
  end

  class CommandError < StandardError
  end
end
