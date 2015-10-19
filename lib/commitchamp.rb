require "httparty"
require "pry"

require "commitchamp/version"
require "commitchamp/github"
# Probably you also want to add a class for talking to github.

module Commitchamp
  class App
    def initialize
      @data = Hash.new
      @git_api = nil
    end

    def run
      token = prompt_user("Enter auth token: ",/^.+$/)
      @git_api = GitHub.new(token)
      org = prompt_user("Enter owner or organization: ",/^.+$/)
      repo_input = prompt_user("Enter repository (leave blank for all repos): ",//)
      repos = get_repos(org,repo_input)
      build_data(org,repos)
      input = nil
      until input == "Q"
        if input == "F"
          @data = Hash.new
          repo_input = prompt_user("Enter repository (leave blank for all repos): ",//)
          repos = get_repos(org,repo_input)
          build_data(org,repos)
        end
        sort_order = get_sort_order
        ordered_data = sort_data(sort_order)
        show_data(ordered_data,sort_order,"#{org}/#{repo_input}")
        input = prompt_user("\nChoose an option:\n  (S) Sort the data differently\n  (F) Fetch another repo\n  (Q) Quit\n",/^[FQS]$/i).upcase
      end
    end


    private
    def get_repos(org,input)
      if input == ""
        repo_data = @git_api.get_repos(org)
        repos = repo_data.map { |x| x["name"] }
      else
        repos = [input]
      end
      repos
    end

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

    def build_data(org,repos)
      repos.each do |repo|
        contributors = @git_api.get_contributors(org,repo)
        contributors.each do |x|
          user = x["author"]["login"].to_sym
          @data[user] ||= Hash.new(0)
          weeks = x["weeks"]
          weeks.each do |w|
            @data[user][:adds] += w["a"]
            @data[user][:deletes] += w["d"]
            @data[user][:changes] += (w["a"] + w["d"])
            @data[user][:total] += w["c"]
          end
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
