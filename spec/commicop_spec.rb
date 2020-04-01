require_relative '../lib/commicop.rb'

RSpec.describe Commicop do
    let(:branch) { 'develop' }
    let(:commicop) { Commicop.new(branch) }
    let(:methods) { [{:method=>"capitalized_subject", :params=>{"Enabled"=>true}},
         {:method=>"subject_length", :params=>{"Max"=>50}},
         {:method=>"body_length", :params=>{"Min"=>10}},
         {:method=>"imperative_subject", :params=>{"Enabled"=>true}},
         {:method=>"body_required", :params=>{"Enabled"=>true}}, 
         {:method=>"valid_grammar", :params=>{"Enabled"=>true}}
        ]}

    describe '#methods_to_check' do
        it 'returns the methods not having the attribute Enable: false' do
            expect(commicop.methods_to_check).to eq(methods)
        end
    end
end