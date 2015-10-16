require "httparty"
require "pry"

require "commitchamp/version"
require "commitchamp/github"
# Probably you also want to add a class for talking to github.

module Commitchamp
  class App
    def initialize
      @token = nil
      @org = nil
      @repo = nil
    end

    def run
      @token = prompt_user("Enter your auth token: ",/^.+$/)
      @org = prompt_user("Enter an organization: ",/^.+$/)
      @repo = prompt_user("Enter a repository: ",/^.+$/)
      ## TODO do we want to check the organizations for the repos they have and have the user pick from that list?
      git_api = GitHub.new(@token)
      contributors = git_api.get_contributors(@org,@repo)

      data = build_data(contributors)

      sort_key = prompt_user(
          "\nChoose a sort order:
            1) lines added
            2) lines deleted
            3) total lines changed
            4) commits made\n",/^[1234]$/).to_i

      case sort_key
        when 1
          sort_order = :additions
        when 2
          sort_order = :deletes
        when 3
          sort_order = :total_commits
        when 4
          sort_order = :changes
        else
          sort_order = :total_commits
          # we really should never get here due to the regex above
      end

      ordered_data = data.sort_by { |key, value| value[sort_order] }.reverse

      show_data(ordered_data,sort_order)

     # prompt_user("Enter (s) to Sort the data differently, (f) to Fetch another repo, or (q) to quit.",)

      binding.pry
    end


    private

    def show_data(data,order)
      puts
      puts "### Contributions for '#{@org}/#{@repo}'"
      puts "##  Ordered by #{order.to_s}"
      puts
      printf("%-20s%10s%10s%10s\n", "Username","Additions","Deletions","Changes")
      data.each do |key, value|
        printf("%-20s%10s%10s%10s\n", "#{key.to_s}","#{value[:adds]}","#{value[:deletes]}","#{value[:changes]}")
      end
    end

    def build_data(contributors)
      data = Hash.new
      contributors.each do |x|
        user = x["author"]["login"].to_sym
        data[user] = Hash.new(0)
        data[user][:total_commits] = x["total"]
        weeks = x["weeks"]
        weeks.each do |w|
          data[user][:adds] += w["a"]
          data[user][:deletes] += w["d"]
          data[user][:changes] += w["c"]
        end
      end
      data
    end

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
