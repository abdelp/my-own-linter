class GitCommit
  attr_reader :subject, :body, :message

  def initialize(commit, git_dir)
    @commit = commit
    @git_dir = git_dir
    @message = `git --git-dir #{@git_dir} log --format=%B -n 1 #{@commit}`
    @message = @message.gsub(/\n/, ' ').strip!
    self.subject = @message.split(/\n/).first
    self.body = @message.partition("\n\n")[2]
  end

  attr_writer :subject, :body
end
