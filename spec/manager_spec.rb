require 'spec_helper'

describe SuperStack::Manager do
  subject {SuperStack::Manager.new}


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

    def file_from_layer(layer_number)
      File.expand_path("../../test/stacked_layer_#{layer_number}.yml", __FILE__)
    end

    (1..4).each do |layer_number|
      let("layer#{layer_number}".to_sym) {
        file_name = file_from_layer layer_number
        layer = SuperStack::Layer.new
        layer.load file_name
        layer.name = "layer#{layer_number}"
        layer
      }
    end

    SuperStack::MergePolicies.list.each do |policy|
      it "should provide a merged view of the layers according to the merge policy: #{policy}" do
        subject.add_layer layer1
        subject.add_layer layer2
        subject.add_layer layer3
        subject.add_layer layer4
        subject.merge_policy = policy
        expect(subject[].is_a? Hash).to be_truthy
        expect(subject[:layer] == 'four').to be_truthy
      end
    end




  end

end