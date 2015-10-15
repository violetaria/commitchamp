require "httparty"
require "pry"

require "commitchamp/version"
require "commitchamp/github"
# Probably you also want to add a class for talking to github.

module Commitchamp
  class App
    def initialize
    end

    def run
      token = prompt_user("Enter your auth token: ",/^.+$/)
      org = prompt_user("Enter an organization: ",/^.+$/)
      repo = prompt_user("Enter a repository: ",/^.+$/)
      ## TODO do we want to check the organizations for the repos they have and have the user pick from that list?
      git_api = GitHub.new(token)

      contributors = git_api.get_contributors(org,repo)

      data = Hash.new

      contributors.each do |x|
        user = x["author"]["login"].to_sym
        data[user] = Hash.new(0)
        data[user][:total_commits] = x["total"]
        weeks = x["weeks"]
        weeks.each do |w|
          data[user][:adds] += w["a"]
          data[user][:deletes] += w["d"]
          data[user][:commits] += w["c"]
        end
        puts "user: #{user} data: #{data[user]}"
      end
      binding.pry
    end


    private
    def prompt_user(text,regex)
      print text
      input = STDIN.gets.chomp
      until input =~ regex
        print text
        input = STDIN.gets.chomp
      end
      input
    end

  end
end


app = Commitchamp::App.new
app.run
