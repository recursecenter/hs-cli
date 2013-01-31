require 'net/http'

module HS
  API_URL = "http://localhost:5000/api/alpha"

  class CodeReviewClient
    def initialize(api_secret)
      @default_data = {:api_secret => api_secret}
    end

    # /codereview/requests
    #
    # data: { body: required,
    #         repo: required,
    #         branch: optional (default: "master"),
    #         api_secret: optional (overrides initialized api_secret) }
    #

    def request(data)
      validate_keys! data, [:body, :repo]

      default_data = {:branch => "master"}
      post "requests", default_data.merge(data)
    end

    # /codereview/responses
    #
    # data: { url: required,
    #         repo: required,
    #         base_repo: required,
    #         branch: optional (default: "master"),
    #         base_branch: optional (default: "master"),
    #         completed: optional (default: false),
    #         api_secret: optional (overrides initialized api_secret) }
    #

    def respond(data)
      validate_keys! data, [:url, :repo, :base_repo]

      default_data = {:branch => "master", :base_branch => "master"}
      post "responses", default_data.merge(data)
    end

    private

    def post(resource, data)
      uri = URI.parse "#{API_URL}/codereview/#{resource}"
      http = ::Net::HTTP.new uri.host, uri.port

      request = ::Net::HTTP::Post.new uri.request_uri
      request.set_form_data @default_data.merge(data)

      response = http.request(request)
    end

    def validate_keys!(data, keys)
      missing = keys.select { |key| !data.has_key? key }
      unless missing.empty?
        raise HS::APIError, "data missing keys: #{missing.join(", ")}"
      end
    end
  end

  class HS::APIError < Exception
  end
end

