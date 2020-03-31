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

            if subject != subject.capitalize
                @offenses << { sha1: commit, err_code: err_code, sugesstion: sugesstion, err_line: subject }
            end
        end
    end

    def imperative_subject
        err_msg = 'No standard imperative verb for subject'.freeze
        sugesstion = 'Use an standardized imperative verb for subject'.freeze
        err_code = 'Layout/ImperativeSubject'.freeze
        imperative_verbs = ['add', 'update', 'fix', 'feat', 'docs', 'style', 'refactor', 'test', 'chore']

        @unpushed_commits.each do |commit|
            message = `git log --format=%B -n 1 #{commit}`
            subject = message.split(/\n/).first

            if imperative_verbs.none? { |verb| verb == subject.downcase }
                @offenses << { sha1: commit, err_code: err_code, sugesstion: sugesstion, err_line: subject }
            end
        end
    end

    def subject_length
        err_code = 'Layout/SubjectLenght'.freeze
        sugesstion = ''.freeze

        @unpushed_commits.each do |commit|
            message = `git log --format=%B -n 1 #{commit}`
            subject = message.split(/\n/).first

            if subject.size > 50
                sugesstion = "Subject is too long [#{subject.size}/50]".freeze
                
                @offenses << { sha1: commit, err_code: err_code, sugesstion: sugesstion, err_line: subject }
            end
        end
    end

    def valid_grammar
        err_code = 'Layout/ValidGrammar'.freeze
        gbot = Grammarbot::Client.new(api_key: ENV['API_KEY'], language: 'en-US', base_uri: ENV['BASE_URI'])

        @unpushed_commits.each do |commit|
            message = `git log --format=%B -n 1 #{commit}`
            message = message.gsub(/\n/, ' ').strip!
            result = gbot.check(message)
            sugesstion = result.matches.first.message
            @offenses << { sha1: commit, err_code: err_code, sugesstion: sugesstion, err_line: message }
        end
    end

    def body_required
        err_msg = 'No message body detected'.freeze
        sugesstion = 'Add a body message'.freeze
        err_code = 'Layout/BodyRequired'.freeze

        @unpushed_commits.each do |commit|
            message = `git log --format=%B -n 1 #{commit}`

            body = message.partition("\n\n")[2]

            if body.empty?
                @offenses << { sha1: commit, err_code: err_code, sugesstion: sugesstion, err_line: message }
            end
        end
    end

    def body_length
        err_msg = 'Body length is too short'.freeze
        err_code = 'Layout/BodyRequired'.freeze

        @unpushed_commits.each do |commit|
            message = `git log --format=%B -n 1 #{commit}`

            body = message.partition("\n\n")[2]

            if body.size < 10 && body.size > 0
                sugesstion = "Body is too short [#{body.size}/10]"
                @offenses << { sha1: commit, err_code: err_code, sugesstion: sugesstion, err_line: message }
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
        output.concat("\n\n#{@unpushed_commits.size} commits inspected, #{@offenses.size} offenses detected")
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