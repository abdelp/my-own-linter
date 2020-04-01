require 'yaml'
require 'grammarbot'
require 'dotenv/load'
require_relative 'string.rb'
require_relative 'error.rb'
require_relative 'gitcommit.rb'

class Commicop
  include ErrorsModule

  def initialize(branch, git_dir)
    @git_dir = git_dir
    branch_exists = system("git --git-dir #{@git_dir} show-ref --verify --quiet refs/heads/#{branch}")
    raise NoBranchFoundError, "No branch #{branch} found" unless branch_exists

    @branch = branch
    @offenses = []
    @commits_inspected = 0
    @unpushed_commits = []
    unpushed_commits
  end

  def methods_to_check
    cnf = YAML.load_file(File.join(__dir__, '../.commicop.yml'))
    methods_to_check = []

    cnf.each do |item, v|
      disabled = v['Enabled'] == false
      methods_to_check << { method: item.underscore, params: v } unless disabled
    end

    methods_to_check
  end

  def check_params
    methods_to_check.each do |item|
      send(item[:method])
    end
  end

  def capitalized_subject
    sugesstion = 'Use capitalized message subjects'.freeze
    err_code = 'Style/CapitalizedSubject'.freeze

    @unpushed_commits.each do |commit|
      git_commit = GitCommit.new(commit, @git_dir)

      # puts git_commit
      # # message = `git log --format=%B -n 1 #{commit}`
      # # subject = message.split(/\n/).first

      if git_commit.subject != git_commit.subject.capitalize
        @offenses << { sha1: commit, err_code: err_code, sugesstion: sugesstion, err_line: git_commit.subject }
      end
    end
  end

  def imperative_subject
    sugesstion = 'Use an standardized imperative verb for subject'.freeze
    err_code = 'Layout/ImperativeSubject'.freeze
    imperative_verbs = %w[add update fix feat docs style refactor test chore]

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

      next unless subject.size > 50

      sugesstion = "Subject is too long [#{subject.size}/50]".freeze

      @offenses << { sha1: commit, err_code: err_code, sugesstion: sugesstion, err_line: subject }
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
    sugesstion = 'Add a body message'.freeze
    err_code = 'Layout/BodyRequired'.freeze

    @unpushed_commits.each do |commit|
      message = `git log --format=%B -n 1 #{commit}`

      body = message.partition("\n\n")[2]

      @offenses << { sha1: commit, err_code: err_code, sugesstion: sugesstion, err_line: message } if body.empty?
    end
  end

  def body_length
    err_code = 'Layout/BodyRequired'.freeze

    @unpushed_commits.each do |commit|
      message = `git log --format=%B -n 1 #{commit}`

      body = message.partition("\n\n")[2]

      if body.size < 10 && body.size.positive?
        sugesstion = "Body is too short [#{body.size}/10]"
        @offenses << { sha1: commit, err_code: err_code, sugesstion: sugesstion, err_line: message }
      end
    end
  end

  def formatted_result
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

  def unpushed_commits
    last_pushed_commit = `git rev-parse origin/#{@branch}`.chomp
    @unpushed_commits = `git rev-list #{last_pushed_commit}..HEAD`.chomp.split(/\n+/)
  end
end
