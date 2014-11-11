require 'spec_helper'

describe SuperStack::Layer do

  subject {SuperStack::Layer.new}

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

  context 'when loading from a YAML file' do
    let(:test_set) do
      %w(empty standard containing_an_array well_formatted).map do |file_type|
        File.expand_path "../../test/layer_content_type_#{file_type}.yml", __FILE__
      end
    end

    %w(empty standard containing_an_array well_formatted).each do |file_type|
      it "should allow #{file_type} content type" do
        expect {
          subject.load File.expand_path("../../test/layer_content_type_#{file_type}.yml", __FILE__)
        }.not_to raise_error
      end
    end

  end





end