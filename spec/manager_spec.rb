require 'spec_helper'


describe SuperStack::Manager do
  subject {SuperStack::Manager.new}

  (1..4).each do |layer_number|
    let("layer#{layer_number}".to_sym) {
      file_name = file_from_layer layer_number
      layer = SuperStack::Layer.new
      layer.load file_name
      layer.name = "layer#{layer_number}"
      layer
    }
  end


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

    expect(subject.layers.count == 2).to be_truthy

    expect(subject.to_a[0] == l1).to be_truthy
    expect(subject.to_a[1] == l2).to be_truthy
  end

  it 'should have a default policy' do
    expect( subject.respond_to? :default_merge_policy).to be_truthy
    expect( subject.respond_to? :'default_merge_policy=').to be_truthy
  end

  it 'should have a default merge policy' do
    expect( subject.default_merge_policy == SuperStack::Manager::DEFAULT_MERGE_POLICY).to be_truthy
  end

  it 'should not accept stupid policies' do
    expect {subject.default_merge_policy = :foo}.to raise_error
  end

  it 'should support pure hashes as layers' do
    expect {subject.add_layer({}) }.not_to raise_error
    expect {subject.add_layer({}) }.not_to raise_error
    expect(subject.layers.keys.count == 2).to be_truthy
    expect(subject.layers.keys[0] == SuperStack::Layer::DEFAULT_LAYER_NAME).to be_truthy
    expect(subject.layers.keys[1] == "#{SuperStack::Layer::DEFAULT_LAYER_NAME} #2").to be_truthy
  end

  it 'should allow the same layer to be added multiple times, automatically changing names' do
    expect {subject.add_layer(layer1) }.not_to raise_error
    expect {subject.add_layer(layer1) }.not_to raise_error
    expect {subject.add_layer(layer1) }.not_to raise_error
    expect(subject.layers.keys.count == 3).to be_truthy
    expect(subject.layers.keys[0] == 'layer1').to be_truthy
    expect(subject.layers.keys[1] == 'layer1 #2').to be_truthy
    expect(subject.layers.keys[2] == 'layer1 #3').to be_truthy
  end

  it 'should allow to reload all layers at once' do
    subject.add_layer layer1
    subject << {bar: :foo}
    subject.add_layer layer3
    subject.add_layer layer4
    expect(subject[:foo] == :bar).to be_falsey
    subject.layers['layer3'][:foo] = :bar
    expect(subject[:foo] == :bar).to be_truthy
    expect(subject[:bar] == :foo).to be_truthy
    expect {subject.reload_layers}.not_to raise_error
    expect(subject[:foo] == :bar).to be_falsey
    expect(subject[:bar] == :foo).to be_truthy
  end

  it 'should be possible to specify a write layer using its name or itself' do
    override = SuperStack::Layer.new
    override.name = :override
    subject << override
    subject << layer1
    expect {subject.write_layer = :override}.not_to raise_error
    expect {subject.write_layer = 'override'}.not_to raise_error
    expect {subject.write_layer = override}.not_to raise_error
  end



  SuperStack::MergePolicies.list.each do |policy|
    it "should provide a merged view of the layers according to the merge policy: #{policy}" do
      subject.add_layer layer1
      subject.add_layer layer2
      subject.add_layer layer3
      subject.add_layer layer4
      subject.default_merge_policy = policy
      expect(subject[].is_a? Hash).to be_truthy
      policy == SuperStack::MergePolicies::KeepPolicy ?
          expect(subject[:layer] == 'one').to(be_truthy) : expect(subject[:layer] == 'four').to(be_truthy)
    end
  end

  context 'when using policies at layer level' do

    it 'should override the default manager policy' do
      subject.add_layer layer1
      subject.add_layer layer2
      subject.default_merge_policy = SuperStack::MergePolicies::FullMergePolicy
      layer2.merge_policy = SuperStack::MergePolicies::OverridePolicy

      expect(subject[:from_layer_1]).to be_nil
      expect(subject[:from_layer_2]).not_to be_nil

    end

  end

end