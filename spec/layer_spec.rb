require 'spec_helper'

describe SuperStack::Layer do

  subject {SuperStack::Layer.new}
  let(:layer_file_type_1) {File.expand_path '../../test/layer_content_type_1.yml', __FILE__}
  let(:layer_file_type_2) {File.expand_path '../../test/layer_content_type_2.yml', __FILE__}
  let(:layer_file_type_3) {File.expand_path '../../test/layer_content_type_3.yml', __FILE__}

  let(:layer_type_set) {[layer_file_type_1, layer_file_type_2, layer_file_type_3]}

  it 'has a name' do
    expect(subject.respond_to? :name).to be_truthy
    expect(subject.respond_to? :name=).to be_truthy
  end

  it 'has a default name' do
    expect(subject.name == subject.class.const_get('DEFAULT_LAYER_NAME')).to be_truthy
  end

  it 'should allow to change the name' do
    subject.name = 'foo'
    expect(subject.name == 'foo').to be_truthy
  end

  it 'should have a priority' do
    expect(subject.respond_to? :priority).to be_truthy
    expect(subject.respond_to? :priority=).to be_truthy
  end

  it 'should be loadable from a YAML file' do
    layer_type_set.each do |file_name|
      expect {
        subject.load file_name
      }.not_to raise_error
    end
  end





end