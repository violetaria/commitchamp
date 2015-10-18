require "httparty"
require "pry"

require "commitchamp/version"
require "commitchamp/github"
# Probably you also want to add a class for talking to github.

module Commitchamp
  class App
    def initialize
      @data = Hash.new
    end

    def run
      token = prompt_user("Enter your auth token: ",/^.+$/)
      git_api = GitHub.new(token)
      org = prompt_user("Enter an owner or organization: ",/^.+$/)
      repos = prompt_user("Enter a repository (leave blank for all repos for an org): ",//).split
      if repos.count == 0
        repo_data = git_api.get_repos(org)
        repos = repo_data.map { |x| x["name"] }
      end
      repos.each do |repo|
        contributors = git_api.get_contributors(org,repo)
        build_data(contributors) unless contributors.nil?
      end
      input = nil
      until input == "Q"
        if input == "F"
          @data = Hash.new
          repo = prompt_user("Enter a repository: ",/^.+$/)
          contributors = git_api.get_contributors(org,repo)
          build_data(contributors) unless contributors.nil?
        end
        sort_order = get_sort_order
        ordered_data = sort_data(sort_order)
        show_data(ordered_data,sort_order,"#{org}/#{repo}")
        input = prompt_user("\nChoose an option:\n  (S) Sort the data differently\n  (F) Fetch another repo\n  (Q) Quit\n",/^[FQS]$/i).upcase
      end
    end


    private

    def get_sort_order
      sort_key = prompt_user("\nChoose a sort order:\n  (A) Lines Added\n  (D) Lines Deleted\n  (C) Lines Changed\n  (T) Total Commits\n",/^[ADCT]$/i).upcase
      case sort_key
        when "A"
          :adds
        when "D"
          :deletes
        when "T"
          :total
        when "C"
          :changes
        else
          :total
          # we should never get here but RubyMine was complaining
      end
    end

    def sort_data(sort_order)
      @data.sort_by { |key, value| value[sort_order] }.reverse
    end

    def show_data(ordered_data,order,title)
      puts
      puts "### Contributions for '#{title}'"
      puts "##  Ordered by #{order.to_s}"
      puts
      printf("%-20s%10s%10s%10s%10s\n", "Username","Additions","Deletions","Changes","Commits")
      ordered_data.each do |key, value|
        printf("%-20s%10s%10s%10s%10s\n", "#{key.to_s}","#{value[:adds]}","#{value[:deletes]}","#{value[:changes]}","#{value[:total]}")
      end
    end

    def build_data(contributors)
      contributors.each do |x|
        user = x["author"]["login"].to_sym
        @data[user] = Hash.new(0)
        weeks = x["weeks"]
        weeks.each do |w|
          @data[user][:adds] += w["a"]
          @data[user][:deletes] += w["d"]
          @data[user][:changes] += (w["a"] + w["d"])
          @data[user][:total] += w["c"]
        end
      end
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
