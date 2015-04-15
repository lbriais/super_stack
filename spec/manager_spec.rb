require 'spec_helper'
require 'tempfile'

describe SuperStack::Manager do
  subject {described_class.new}

  (1..4).each do |layer_number|
    let("layer#{layer_number}".to_sym) {
      file_name = file_from_layer layer_number
      layer = SuperStack::Layer.new
      layer.load file_name
      layer.name = "layer#{layer_number}"
      layer
    }
  end
  let(:override) {
    override = SuperStack::Layer.new
    override.name = :override
    override
  }


  it 'should contain layers' do
    expect( subject.respond_to? :layers).to be_truthy
  end

  it 'should be added as manager to added layers' do
    subject.add_layer({})
    expect(subject.layers.values.first.manager == subject).to be_truthy
  end


  it 'should call managed on layer when adding it' do
    layer = {}
    class << layer
      def managed
        return :yo
      end
    end
    expect(layer).to receive(:managed)
    subject << layer
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

  it 'should have a default merge policy' do
    expect( subject.respond_to? :default_merge_policy).to be_truthy
    expect( subject.respond_to? :'default_merge_policy=').to be_truthy
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

  it 'should allow to reload all layers at once' do
    subject.add_layer layer1
    subject << {bar: :foo}
    subject.add_layer layer3
    subject.add_layer layer4
    expect(subject[:foo]).not_to eq :bar
    subject.layers['layer3']['foo'] = :bar
    expect(subject[:foo]).to eq :bar
    expect(subject[:bar]).to eq :foo
    expect {subject.reload_layers}.not_to raise_error
    expect(subject[:foo]).not_to eq :bar
    expect(subject[:bar]).to eq :foo
  end

  it 'should not be possible to modify the manager if no write layer has been specified' do
    subject << layer1
    subject << layer2
    expect {subject[:foo] = :bar}.to raise_error
  end

  context 'when specifying a write layer' do

    it 'should be possible using its name or itself' do
      subject << override
      subject << layer1
      expect {subject.write_layer = :override}.not_to raise_error
      expect {subject.write_layer = 'override'}.not_to raise_error
      expect {subject.write_layer = override}.not_to raise_error
    end

    it 'should push all modifications to the write layer' do
      subject << override
      subject << layer1
      subject.write_layer = override
      expect {subject[:foo] = :bar}.not_to raise_error
      expect(subject.layers['override']['foo']).to eq :bar
      expect(subject[:foo]).to eq :bar
      expect(subject['foo']).to eq :bar
    end


    it 'should be possible to clear modifications' do
      subject << layer1
      subject << override
      subject.write_layer = override
      subject[:something_modified] = :modified
      expect(subject[:something_modified]).not_to be_nil
      subject.reset
      expect(subject[:something_modified]).to be_nil
    end

    it 'should not be possible to specify a disabled layer' do
      subject << override
      subject.write_layer = override
      subject.disable_layer override
      expect {subject.write_layer = override}.to raise_error
    end

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

  context 'when removing a layer' do

    subject {
      s = SuperStack::Manager.new
      s.add_layer layer1
      s.add_layer layer2
      s.add_layer layer3
      s.add_layer layer4
      s
    }


    it 'should not accept an incorrect layer' do
      expect {subject.remove_layer :layer12}.to raise_error
      expect {subject.remove_layer nil}.to raise_error
    end

    it 'should accept a symbol' do
      expect {subject.remove_layer :layer3}.not_to raise_error
    end
    it 'should accept a string' do
      expect {subject.remove_layer 'layer3'}.not_to raise_error
    end
    it 'should accept a layer itself' do
      expect {subject.remove_layer layer3}.not_to raise_error
    end
    it 'should not manage the layer anymore' do
      subject.remove_layer :layer3
      expect(layer3.manager).to be_nil
    end

    it 'should remain consistent in terms of merged view' do
      subject.remove_layer :layer3
      expect(subject[:from_layer_3]).to be_nil
      expect(subject[:from_layer_1]).not_to be_nil
      expect(subject[:from_layer_2]).not_to be_nil
      expect(subject[:from_layer_4]).not_to be_nil
    end

    it 'should remain consistent regarding the write level' do
      subject.write_layer = :layer3
      expect(subject.write_layer).to eq layer3
      subject[:foo] = :bar
      expect(layer3['foo']).to eq :bar
      subject.remove_layer :layer3
      expect(subject[:foo]).not_to eq :bar
      expect(subject['foo']).not_to eq :bar
      expect(subject.write_layer).to be_nil
    end

  end

  context 'when disabling a layer' do

    subject {
      s = SuperStack::Manager.new
      s.add_layer layer1
      s.add_layer layer2
      s.add_layer layer3
      s.add_layer layer4
      s
    }

    it 'should not been taken in account in the merge' do
      subject.disable_layer :layer3
      expect(subject[:from_layer_3]).to be_nil
      expect(subject[:from_layer_1]).not_to be_nil
      expect(subject[:from_layer_2]).not_to be_nil
      expect(subject[:from_layer_4]).not_to be_nil
    end

    it 'could be reactivated' do
      subject.disable_layer :layer3
      subject.enable_layer :layer3
      expect(subject[:from_layer_3]).not_to be_nil
      expect(subject[:from_layer_1]).not_to be_nil
      expect(subject[:from_layer_2]).not_to be_nil
      expect(subject[:from_layer_4]).not_to be_nil
    end

    context 'when enabling/disabling a layer which is the write layer' do
      subject {
        s = SuperStack::Manager.new
        s.add_layer layer1
        s.add_layer layer2
        s.add_layer layer3
        s.add_layer layer4
        s.write_layer = :layer3
        s
      }
      it 'should restore it as the write layer if re-enabled' do
        subject.disable_layer :layer3
        expect(subject.write_layer).to be_nil
        subject.enable_layer :layer3
        expect(subject.write_layer).to be layer3
        expect {subject[:foo] = :bar}.not_to raise_error
      end

      it 'should not restore it as the write layer if another write layer has been set in between' do
        subject.disable_layer :layer3
        expect(subject.write_layer).to be_nil
        subject.write_layer = :layer2
        subject.enable_layer :layer3
        expect(subject.write_layer).to be layer2
        expect {subject[:foo] = :bar}.not_to raise_error
      end
    end


  end

  context 'when #enable_source_auto_reload is set on a layer' do
    let(:source_file) do
      f = Tempfile.new 'synced_test_config_file'
      f.puts 'in_synced_config_file: foo'
      f.close
      f.path
    end

    let(:synced_layer) do
      layer = SuperStack::Layer.new
      layer.load source_file
      layer.name = 'Synchronized layer'
      layer.enable_source_auto_reload
      layer
    end

    after(:all) do
      source_file.close
      source_file.unlink
    end

    it 'should reflect any change applied to the source' do
      subject << synced_layer
      File.open(source_file, 'a') do |f|
        f.puts 'extra_foo: extra_bar'
      end
      puts subject[].to_yaml
      expect(subject['extra_foo']).to eq 'extra_bar'
    end


  end

end