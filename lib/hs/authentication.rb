require 'netrc'

module HS
  module Authentication

    HSCONFIG_FILE = File.expand_path '~/.hsconfig'

    module_function

    def api_secret
      File.read(HSCONFIG_FILE)
    end

    def require_credentials
      store_api_secret unless api_secret_stored?
      store_github_creds unless github_creds_stored?
      true
    end

    def store_api_secret
      File.open(HSCONFIG_FILE, 'w') do |f|
        f.write request_api_secret
      end
    end

    def request_api_secret
      gets_non_empty "Hacker School API secret key: "
    end

    def api_secret_stored?
      File.exists?(HSCONFIG_FILE) && !File.read(HSCONFIG_FILE).empty?
    end

    def store_github_creds
      netrc = Netrc.read
      netrc['api.github.com'] = request_github_creds
      netrc.save
    end

    def request_github_creds
      username = gets_non_empty "GitHub username: "
      password = gets_non_empty "GitHub password: "
      [username, password]
    end

    def github_creds_stored?
      not Netrc.read['api.github.com'].nil?
    end

    def gets_non_empty(prompt)
      print prompt
      input = $stdin.gets.chomp
      input.empty? ? gets_non_empty(prompt) : input
    end
  end
end
