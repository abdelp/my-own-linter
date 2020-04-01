require_relative '../lib/commicop.rb'

RSpec.describe Commicop do
  let(:branch) { 'master' }
  let(:git_dir) { ENV['DEFAULT_GIT_DIR'] }
  let(:last_pushed_commit) { `git --git-dir #{@git_dir} rev-parse origin/#{@branch}`.chomp }
  let(:commits_list) { `git --git-dir #{@git_dir} rev-list #{last_pushed_commit}..HEAD --abbrev-commit`.chomp.split(/\n+/) }
  let(:commicop) { Commicop.new(branch, git_dir) }
  let(:non_existent_branch) { 'dvelop' }
  let(:non_capitalized_subject) { [{:err_code=>"Style/CapitalizedSubject", :err_line=>"add readme.txt\n\ncheck if", :sha1=>"05ad1f4d94b85019caf8f6b66f73fd7a44c9f0d8", :sugesstion=>"Use capitalized message subjects"}]
}
  let(:subject_too_long) {[{:err_code=>"Layout/SubjectLenght", :err_line=>"Add subject length with more than 50 characters check...", :sha1=>"b1822c4c5968fa7ba534993b58d4c26ba353a0d6", :sugesstion=>"Subject is too long [56/50]"}]
}
  let(:methods) do
    [{ method: 'capitalized_subject', params: { 'Enabled' => true } },
     { method: 'subject_length', params: { 'Enabled' => true } },
     { method: 'body_length', params: { 'Enabled' => true } },
     { method: 'imperative_subject', params: { 'Enabled' => true } },
     { method: 'body_required', params: { 'Enabled' => true } },
     { method: 'valid_grammar', params: { 'Enabled' => true } }]
  end

  describe '#initialize' do
    it 'throws an NoBranchFoundError when is initialized with a non existent branch' do
      expect { Commicop.new(non_existent_branch, git_dir) }.to raise_error(ErrorsModule::NoBranchFoundError)
    end
  end

  describe '#methods_to_check' do
    it 'returns the methods not having the attribute "Enabled: false"' do
      expect(commicop.methods_to_check).to eq(methods)
    end
  end

  describe '#capitalized_subject' do
    it 'loads into the offenses array all the commits where subject is not capitalized' do
      commicop.capitalized_subject
      expect(commicop.offenses).to eq(non_capitalized_subject)
    end
  end

  describe '#imperative_subject' do
    it 'checks the subjects without imperative verb' do
      commicop.imperative_subject
      expect(commicop.offenses).to eq(non_capitalized_subject)
    end
  end

  describe '#subject_length' do
    it 'checks the subject has no more than 50 characters' do
      commicop.subject_length
      expect(commicop.offenses).to eq(subject_too_long)
    end
  end
end
