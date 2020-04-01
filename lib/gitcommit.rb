class GitCommit
    attr_reader :subject, :body

    def initilize(commit)
        @commit = commit
        @git_dir = git_dir
        puts "---------" + git_dir
        @message = `git --git-dir #{@git_dir} log --format=%B -n 1 #{@commit}`
        self.subject = @message.split(/\n/).first
        self.body = @message.partition("\n\n")[2]
    end
end