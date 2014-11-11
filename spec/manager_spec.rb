require 'spec_helper'

describe SuperStack::Manager do
  subject {SuperStack::Manager.new}

  it 'should contain layers' do
    expect( subject.respond_to? :layers).to be_truthy
  end

  it 'should present layers ordered by priority'


end