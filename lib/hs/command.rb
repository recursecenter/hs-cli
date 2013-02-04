require 'octokit'
require 'git'
require 'net/http'

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
      require_message "\n# Code review request description"

      repo = File.basename(Dir.getwd)
      resp = @hs.request body: @opts[:message],
                         repo: repo,
                         branch: @opts[:branch]

      # HTTPResponse#value raises an HTTPError if the status code is not 2xx
      begin resp.value
        puts "Hacker School code review requested for #{repo}:#{@opts[:branch]}. Please remember to push recent changes to GitHub!"
      rescue ::Net::HTTPError
        puts resp.body
      end
    end

    def review
      args = parse_review_args
      review_branch = "#{args[:branch]}-review"

      # sleep to give GH a chance to update refs
      (clone_url, source_url = gh_fork "#{args[:username]}/#{args[:repo]}") and sleep(1)
      git_repo = clone_locally clone_url, args[:name] if clone_url

      if git_repo
        git_repo.branch(review_branch).checkout
        git_repo.push(git_repo.remote('origin'), review_branch)
        git_repo.add_remote('upstream', source_url)
        @hs.respond url: "#{clone_url.chomp('.git')}/tree/#{review_branch}",
                    repo: args[:repo],
                    branch: review_branch,
                    base_repo: args[:repo],
                    base_branch: args[:branch],
                    completed: false

        puts "A review branch (#{review_branch}) has been created in local repository #{args[:name]}. Happy reviewing!"
      else
        puts "Failed"
      end
    end

    def submit
      require_message "\n# Pull request description"

      git_repo = Git.init '.'
      head = git_repo.current_branch
      base = head.chomp "-review"
      base_url = git_repo.remote('upstream').url.chomp('.git')
      head_url = git_repo.remote('origin').url.chomp('.git')
      userhead = "#{extract_username_from_url head_url}:#{head}"
      upstream_repo = ::Octokit::Repository.from_url(base_url)
      resp = @gh.create_pull_request(upstream_repo, base, userhead, "Code review", @opts[:message])

      pull_url = resp[:html_url]
      repo_name = upstream_repo.name.chomp '.git'
      @hs.respond url: pull_url,
                  repo: repo_name,
                  branch: head,
                  base_repo: repo_name,
                  base_branch: base,
                  completed: true

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
      username, repo_branch = repo_arg.split '/'

      unless username && repo_branch
        raise CommandError, "Username and repo must be specified."
      end

      repo, branch = repo_branch.split ':'

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

    def extract_username_from_url(url)
      /https?:\/\/(www\.)?github\.com\/(?<un>[^\/]*)(\/.*)?/.match(url)[:un]
    end
  end

  class CommandError < Exception
  end
end
