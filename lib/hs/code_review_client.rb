require 'net/http'

module HS
  API_URL = "#{ENV['HS_API_URL'] || "https://www.hackerschool.com"}/api/alpha"

  class CodeReviewClient
    def initialize(api_secret)
      @default_data = {:api_secret => api_secret}
    end

    # POST /person/review_requests
    #
    # data: { body: required,
    #         repo: required,
    #         github_account: required,
    #         branch: optional (default: "master"),
    #         api_secret: optional (overrides initialized api_secret) }
    #

    def request(data)
      validate_keys! data, [:body, :repo, :github_account]

      default_data = {:branch => "master"}
      post "review_requests", default_data.merge(data)
    end

    # POST /person/review_responses
    #
    # data: { url: required,
    #         repo: required,
    #         base_github: required,
    #         base_repo: required,
    #         branch: optional (default: "master"),
    #         base_branch: optional (default: "master"),
    #         completed: optional (default: false),
    #         api_secret: optional (overrides initialized api_secret) }
    #

    def respond(data)
      validate_keys! data, [:url, :repo, :base_repo, :base_github]

      default_data = {:branch => "master", :base_branch => "master"}
      post "review_responses", default_data.merge(data)
    end

    private

    def post(resource, data)
      url = URI.parse("#{API_URL}/person/#{resource}")
      http = ::Net::HTTP.new(url.host, url.port)

      if url.scheme == 'https'
        http.use_ssl = true
      end

      req = ::Net::HTTP::Post.new(url.path)
      req.form_data = @default_data.merge(data)
      require 'pry'
      binding.pry
      http.request(req)
    end

    def validate_keys!(data, keys)
      data = symbolize_keys(data)
      missing = keys.select { |key| !data.has_key? key }
      unless missing.empty?
        raise HS::APIError, "data missing keys: #{missing.join(", ")}"
      end
    end

    def symbolize_keys(hsh)
      Hash[hsh.map { |k, v| [k.to_sym, v] }]
    end
  end

  class HS::APIError < Exception
  end
end

