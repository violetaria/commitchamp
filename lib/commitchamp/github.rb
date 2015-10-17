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

    def get_repos(org,options={})
      self.class.get("/orgs/#{org}/repos",
                    headers: @auth,
                    body: options.to_json)
    end

  end
end

