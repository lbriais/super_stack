require 'spec_helper'

describe SuperStack::MergePolicies do

  subject {SuperStack::MergePolicies}

  def file_from_layer(layer_number)
    File.expand_path("../../test/stacked_layer_#{layer_number}.yml", __FILE__)
  end

  (1..4).each do |layer_number|
    let("layer#{layer_number}".to_sym) {
      file_name = file_from_layer layer_number
      Hash[YAML::load(File.open(file_name)).map { |k, v| [k.to_sym, v] }]
    }
  end


  it 'should have merge policies' do
    policies = subject.list
    expect( policies.is_a? Array).to be_truthy
    expect( policies.count == 3).to be_truthy
  end

  context 'when dealing with override policy' do

    subject {SuperStack::MergePolicies::OverridePolicy}

    it 'should retain only the second hash' do
      merged_hashs = subject.merge(layer1, layer2)
      expect( merged_hashs == layer2).to be_truthy
      expect( merged_hashs[:layer] == 'two').to be_truthy
    end

  end

  context 'when dealing with standard merge policy' do

    subject {SuperStack::MergePolicies::StandardMergePolicy}

    it 'should be merged at first level' do
      merged_hashs = subject.merge(layer1, layer2)
      expect( merged_hashs[:layer] == 'two').to be_truthy
      expect( merged_hashs[:from_layer_1]['stupid-data'] == 'stupid in one').to be_truthy
      expect( merged_hashs[:from_layer_2]['stupid-data'] == 'stupid in two').to be_truthy
      expect( merged_hashs[:'to-be-merged'] == layer2[:'to-be-merged']).to be_truthy
    end

  end

  context 'when dealing with full merge policy' do

    subject {SuperStack::MergePolicies::FullMergePolicy}

    it 'should be merged at all levels' do
      merged_hashs = subject.merge(layer1, layer2)
      expect( merged_hashs[:layer] == 'two').to be_truthy
      expect( merged_hashs[:from_layer_1]['stupid-data'] == 'stupid in one').to be_truthy
      expect( merged_hashs[:from_layer_2]['stupid-data'] == 'stupid in two').to be_truthy
      expect( merged_hashs[:'to-be-merged'] == layer2[:'to-be-merged']).to be_falsey

      expect( merged_hashs[:'to-be-merged']['name'] == 'from layer 2').to be_truthy
      expect( merged_hashs[:'to-be-merged']['my-array'].count == layer1[:'to-be-merged']['my-array'].count + layer2[:'to-be-merged']['my-array'].count).to be_truthy
      # The hashes have 2 keys in common, and bring a new one each, leading to 4.
      expect( merged_hashs[:'to-be-merged']['my-hash'].keys.count == 4).to be_truthy

    end

  end

end
