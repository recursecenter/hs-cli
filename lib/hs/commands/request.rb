module HS
  module Command extend self

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

  end
end
