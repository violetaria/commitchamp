module Commitchamp
  class GitHub
    include HTTParty
    base_uri "https://api.github.com"

    def initialize(auth_token)
      @auth = {
          "Authorization" =>  "token #{auth_token}",
          "User-Agent"    =>  "HTTParty"
      }
    end

    def get_contributors(org,repo)
      self.class.get("/repos/#{org}/#{repo}/stats/contributors",
                    headers: @auth)
    end

  end
end


