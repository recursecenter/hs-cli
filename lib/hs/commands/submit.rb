module HS
  module Command extend self

    def submit
      require_message("\n# Pull request description")

      git_repo = Git.init('.')
      origin_data = remote_data(git_repo, 'origin')
      upstream_data = remote_data(git_repo, 'upstream')

      head = git_repo.current_branch
      base = head.chomp("-review")

      upstream_repo = ::Octokit::Repository.from_url(upstream_data[:url])

      resp = @gh.create_pull_request(upstream_repo, base, "#{origin_data[:username]}:#{head}", "Code review", @opts[:message])

      pull_url = resp[:html_url]
      @hs.respond(:url => pull_url,
                  :repo => origin_data[:repo],
                  :branch => head,
                  :base_github => upstream_data[:username],
                  :base_repo => upstream_data[:repo],
                  :base_branch => base,
                  :completed => true)

      puts "Code review pull request submitted."
    end

  end
end
