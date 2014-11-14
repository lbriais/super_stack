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
    expect( policies.count == 2).to be_truthy
  end

  context 'when dealing with override policy' do

    subject {SuperStack::MergePolicies::OverridePolicy}



    it 'should retain only the second hash' do
      merged_hashs = subject.merge(layer1, layer2)
      expect( merged_hashs == layer2).to be_truthy
      expect( merged_hashs[:layer] == 'two').to be_truthy
    end

  end


end
