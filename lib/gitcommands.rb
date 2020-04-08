module GitCommandsModule
  def branch_exists?(git_dir, branch)
    system("git --git-dir #{git_dir} show-ref --verify --quiet refs/heads/#{branch}")
  end

  def last_pushed_commit(git_dir, branch)
    `git --git-dir #{git_dir} rev-parse origin/#{branch}`.chomp
  end

  def unpushed_commits(git_dir, last_pushed_commit)
    `git --git-dir #{git_dir} rev-list #{last_pushed_commit}..HEAD --abbrev-commit`.chomp.split(/\n+/)
  end
end
