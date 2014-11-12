require 'spec_helper'

describe SuperStack::Manager do
  subject {SuperStack::Manager.new}

  let (:two_layers_subject) {
    m = SuperStack::Manager.new
    layer1 = SuperStack::Layer.new
    layer1.name = :layer1
    layer1.load(File.expand_path '../../test/layer_content_type_standard.yml', __FILE__)
    m.add_layer layer1
    layer2 = SuperStack::Layer.new
    layer2.name = :layer2
    layer2.load(File.expand_path'../../test/layer_content_type_containing_an_array.yml', __FILE__)
    m.add_layer layer2
    m
  }

  it 'should contain layers' do
    expect( subject.respond_to? :layers).to be_truthy
  end

  it 'should present layers ordered by priority' do
    l1 = SuperStack::Layer.new
    l1.priority = 1
    l1.name = :pipo
    l2 = SuperStack::Layer.new
    l2.priority = 2
    l2.name = :bimbo

    subject.add_layer l2
    subject.add_layer l1

    expect(subject.to_a[0] == l1).to be_truthy
    expect(subject.to_a[1] == l2).to be_truthy
  end

  it 'should have a policy' do
    expect( subject.respond_to? :merge_policy).to be_truthy
  end

  it 'should not be ready unless a merge policy is set' do
    expect( subject.ready?).to be_falsey
    subject.merge_policy = SuperStack::MergePolicies.list[0]
    expect( subject.ready?).to be_truthy
  end

  it 'should not accept stupid policies' do
    expect {subject.merge_policy = :foo}.to raise_error
  end

  context 'when ready' do


    it 'should provide a merged view of the layers according to the merge policy chosen' do
      SuperStack::MergePolicies.list.each do |policy|
        two_layers_subject.merge_policy = policy
        expect(two_layers_subject[].is_a? Hash).to be_truthy
      end
    end



  end

end