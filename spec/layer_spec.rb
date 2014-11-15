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

  it 'could have its own merge policy' do
    expect( subject.respond_to? :merge_policy).to be_truthy
    expect( subject.respond_to? :'merge_policy=').to be_truthy
  end

  it 'should allow to change the name' do
    subject.name = 'foo'
    expect(subject.name == 'foo').to be_truthy
  end

  it 'should have a priority' do
    expect(subject.respond_to? :priority).to be_truthy
    expect(subject.respond_to? :priority=).to be_truthy
  end

  it 'should be comparable by priority' do
    other = SuperStack::Layer.new
    subject.priority = 1
    other.priority = 2
    expect( subject < other).to be_truthy
  end

  it 'can be created from any Hash' do
    expect {Hash.new.extend SuperStack::LayerWrapper }.not_to raise_error
  end

  context 'when loaded from a YAML file' do

    def file_from_type(file_type)
      File.expand_path("../../test/layer_content_type_#{file_type}.yml", __FILE__)
    end

    %w(empty standard containing_an_array well_formatted).each do |file_type|
      it "should allow #{file_type} content type" do
        expect {
          subject.load file_from_type file_type
        }.not_to raise_error
        expect( subject.has_file?).to be_truthy
      end
    end


  end





end