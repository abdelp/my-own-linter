require 'yaml'
require 'grammarbot'
require 'dotenv/load'

# 

class Linter
    # include 'error'
    # include 'warning'

    def initialize(branch)
        # raise
        # @methods_to_check = []
        @branch = branch
        @errCount = 0
    end

    def get_methods_to_check
        cnf = YAML::load_file(File.join(__dir__, '../.grammbot.yml'))
        methods_to_check = []

        cnf.each do |item, v|
            disabled = v['Enabled'] == false
            p item.underscore
            methods_to_check << { method: item.underscore, params: v } unless disabled
        end

        methods_to_check
    end

    def check_params
        get_methods_to_check.each do |item|
            p item
            send(item[:method])
        end
    end

    def run
    end

    def capitalized_subject
        @branch = 'feature/initial-setup'
        last_pushed_commit = `git rev-parse origin/#{@branch}`.chomp

        # verificar si hay un last commit que hacer en caso de que no haya? ah.. si.. listar todos nomas
        # if hay un last_pushed_commit

        all_unpushed_commits = `git rev-list #{last_pushed_commit}..HEAD`.chomp
        # verificar si hay alguno

        all_unpushed_commits = all_unpushed_commits.split(/\n+/)

        all_unpushed_commits.each do |commit|
            message = `git log --format=%B -n 1 #{commit}`
            subject = message.split(/\n/).first
            p "subject: #{subject}"

            if subject.size > 50
                p "The commit message is too long"
            end

            message = message.gsub(/\n/, ' ').strip!
            p message
        end
        #result = gbot.check(message)

        # result.language.code # => 'en-US'
        # result.matches.size # => 1
        # p result.matches.first.message
        # gbot = GrammBot.new(api_key: ENV['API_KEY'], language: 'en-US', base_uri: ENV['BASE_URI'])
    end

    private
end

class String
  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    gsub(/^.*\//, '').
    tr("-", "_").
    downcase
  end
end

l = Linter.new(1)
l.check_params