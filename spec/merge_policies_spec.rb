require 'spec_helper'

describe SuperStack::MergePolicies do

  subject {SuperStack::MergePolicies}

  it 'should have merge policies' do
    policies = subject.list
    expect( policies.is_a? Array).to be_truthy
    expect( policies.count == 2).to be_truthy
  end


end
