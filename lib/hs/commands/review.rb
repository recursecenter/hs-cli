module HS
  module Command extend self

    def review
      args = parse_review_args
      review_branch = "#{args[:branch]}-review"

      puts "Forking..."
      resp = @gh.fork("#{args[:username]}/#{args[:repo]}")

      origin_url = resp[:clone_url]
      base_url = resp[:source][:clone_url]

      unless origin_url && base_url
        $stderr.puts "Fork failed. Got response:\n#{resp}"
        exit(1)
      end

      puts "Cloning locally..."
      git = ::Git.clone(base_url, args[:name])

      unless git
        $stderr.puts "Cloning #{base_url} to #{args[:name]} failed."
        exit(1)
      end

      git.add_remote('upstream', base_url)
      git.remote('origin').remove
      git.add_remote('origin', origin_url)

      git.branch(review_branch).checkout
      git.push(git.remote('origin'), review_branch)

      resp = @hs.respond(:url => "#{origin_url.chomp('.git')}/tree/#{review_branch}",
                         :repo => args[:repo],
                         :branch => review_branch,
                         :base_repo => args[:repo],
                         :base_branch => args[:branch],
                         :base_github => github_url_data(base_url)[:username],
                         :completed => false)

      puts <<EOS
A review branch (#{review_branch}) has been created in local repository #{args[:name]}.
Happy reviewing!"
EOS
    end

    def parse_review_args
      repo_arg, name = @args
      username, repo_branch = repo_arg.split('/')

      unless username && repo_branch
        $stderr.puts "Username and repo must be specified."
        exit(1)
      end

      repo, branch = repo_branch.split(':')

      { :username => username,
        :repo => repo,
        :branch => branch || 'master',
        :name => name || repo }
    end

  end
end
