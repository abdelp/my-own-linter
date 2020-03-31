require 'yaml'
require 'grammarbot'
require 'dotenv/load'

class Linter
    def initialize(branch)
        @branch = branch
        @offenses = []
        @commits_inspected = 0
        @unpushed_commits = []
        get_unpushed_commits
    end

    def get_methods_to_check
        cnf = YAML::load_file(File.join(__dir__, '../.grammbot.yml'))
        methods_to_check = []

        cnf.each do |item, v|
            disabled = v['Enabled'] == false
            methods_to_check << { method: item.underscore, params: v } unless disabled
        end

        methods_to_check
    end

    def check_params
        get_methods_to_check.each do |item|
            send(item[:method])
        end
    end

    def capitalized_subject
        err_msg = 'Commit subject not capitalized'.freeze
        sugesstion = 'Use capitalized message subjects'.freeze
        err_code = 'Style/CapitalizedSubject'.freeze

        @unpushed_commits.each do |commit|
            message = `git log --format=%B -n 1 #{commit}`
            subject = message.split(/\n/).first

            if subject != subject.downcase
                @offenses << { sha1: commit, err_code: err_code, sugesstion: sugesstion, err_line: subject }
            end
        end
    end

    def imperative_subject
        err_msg = 'No standard imperative verb for subject'.freeze
        sugesstion = 'Use an standardized imperative verb for subject'.freeze
        err_code = 'Layout/ImperativeSubject'.freeze
        imperative_verbs = ['feat', 'fix', 'docs', 'style', 'refactor', 'test', 'chore']

        @unpushed_commits.each do |commit|
            message = `git log --format=%B -n 1 #{commit}`
            subject = message.split(/\n/).first

            if imperative_verbs.none? { |verb| verb == subject.downcase }
                @offenses << { sha1: commit, err_code: err_code, sugesstion: sugesstion, err_line: subject }
            end
        end
    end

    def get_formatted_result
        output = "Offenses:\n\n"
        @offenses.each do |offense|
            output.concat("#{offense[:sha1]}: #{offense[:err_code]}: #{offense[:sugesstion]}\n")
            output.concat("#{offense[:err_line]}\n")
            output.concat("^\n\n")
        end
        output.concat("\n\n#{@commits_inspected} commits inspected, #{@offenses.size} offenses detected")
        output
    end

    private

    def get_unpushed_commits
        last_pushed_commit = `git rev-parse develop`.chomp
        @unpushed_commits = `git rev-list #{last_pushed_commit}..HEAD`.chomp.split(/\n+/)
    end
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

l = Linter.new('develop')
l.check_params
puts l.get_formatted_result