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
      contributors = query_data
      data = build_data(contributors)
      input = nil
      until input == "Q"
        if input == "F"
          @repo = prompt_user("Enter a repository: ",/^.+$/)
          contributors = query_data
          data = build_data(contributors)
        end
        sort_order = get_sort_order
        ordered_data = sort_data(data,sort_order)
        show_data(ordered_data,sort_order)
        input = prompt_user(
           "Choose an option:
            (S) Sort the data differently
            (F) Fetch another repo
            (Q) Quit\n",/^[FQS]$/i).upcase
      end

      binding.pry
    end


    private

    def get_sort_order
      sort_key = prompt_user(
          "\nChoose a sort order:
            (A) lines Added
            (D) lines Deleted
            (C) lines Changed
            (T) Total Add/Delete/Changes\n",/^[ADCT]$/i).upcase

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

    def sort_data(data,sort_order)
      data.sort_by { |key, value| value[sort_order] }.reverse
    end

    def show_data(data,order)
      puts
      puts "### Contributions for '#{@org}/#{@repo}'"
      puts "##  Ordered by #{order.to_s}"
      puts
      printf("%-20s%10s%10s%10s%10s\n", "Username","Additions","Deletions","Changes","Total")
      data.each do |key, value|
        printf("%-20s%10s%10s%10s%10s\n", "#{key.to_s}","#{value[:adds]}","#{value[:deletes]}","#{value[:changes]}","#{value[:total]}")
      end
    end

    def query_data
      git_api = GitHub.new(@token)
      git_api.get_contributors(@org,@repo)
    end

    def build_data(contributors)
      data = Hash.new
      contributors.each do |x|
        user = x["author"]["login"].to_sym
        data[user] = Hash.new(0)
        weeks = x["weeks"]
        weeks.each do |w|
          data[user][:adds] += w["a"]
          data[user][:deletes] += w["d"]
          data[user][:changes] += w["c"]
          data[user][:total] += (w["a"] + w["d"] + w["c"])
        end
      end
      data
    end

    def prompt_user(text,regex)
      puts
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
