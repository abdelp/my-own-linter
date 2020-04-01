require_relative '../lib/commicop.rb'

RSpec.describe Commicop do
  let(:branch) { 'develop' }
  let(:commicop) { Commicop.new(branch) }
  let(:non_existent_branch) { 'dvelop' }

  let(:methods) do
    [{ method: 'capitalized_subject', params: { 'Enabled' => true } },
     { method: 'subject_length', params: { 'Max' => 50 } },
     { method: 'body_length', params: { 'Min' => 10 } },
     { method: 'imperative_subject', params: { 'Enabled' => true } },
     { method: 'body_required', params: { 'Enabled' => true } },
     { method: 'valid_grammar', params: { 'Enabled' => true } }]
  end

  describe '#initialize' do
    it 'throws an NoBranchFoundError when is initialized with a non existent branch' do
      expect { Commicop.new(non_existent_branch) }.to raise_error(ErrorsModule::NoBranchFoundError)
    end
  end

  describe '#methods_to_check' do
    it 'returns the methods not having the attribute Enable: false' do
      expect(commicop.methods_to_check).to eq(methods)
    end
  end

  describe '#check_params' do
  end

  describe '#capitlized_subject' do
    it 'loads into the offenses array all the commits'
  end
end
