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
      # Your code goes here...
    end



  end
end

print "Please enter your Auth Token: "
token = gets.chomp
print "Please enter an organization: "
org = gets.chomp

## TODO do we want to check the organizations for the repos they have and have the user pick from that list?
print "Please choose a repository: "
repo = gets.chomp

app = Commitchamp::App.new
app.run
