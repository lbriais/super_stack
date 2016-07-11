require 'spec_helper'

describe SuperStack::Layer do

  subject {SuperStack::Layer.new}

  it 'has a name' do
    expect(subject.respond_to? :name).to be_truthy
    expect(subject.respond_to? :name=).to be_truthy
  end

  it 'has a default name' do
    expect(subject.name).not_to be_empty
  end

  it 'should have an auto-reload flag' do
    expect(subject.source_auto_reload).not_to be_nil
    expect(subject).to respond_to :enable_source_auto_reload
    expect(subject).to respond_to :disable_source_auto_reload
    expect(subject).to respond_to :source_auto_reload?
    subject.enable_source_auto_reload
    expect(subject.source_auto_reload?).to be_truthy
    subject.disable_source_auto_reload
    expect(subject.source_auto_reload?).to be_falsey
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
    expect {SuperStack::LayerWrapper.from_hash Hash.new}.not_to raise_error
  end

  context 'when loaded from a YAML file' do

    %w(empty standard containing_an_array well_formatted).each do |file_type|
      it "should allow #{file_type} content type" do
        expect {
          subject.load file_from_type file_type
        }.not_to raise_error
        expect( subject.has_file?).to be_truthy
      end
    end

    it 'should remain unchanged when trying to load an invalid file' do
      subject[:foo] = :bar
      expect {
        subject.load file_from_type 'invalid'
      }.to raise_error

      expect(subject[:foo] == :bar).to be_truthy
    end

    it 'should override current values when loaded from a valid file' do
      subject[:foo] = :bar
      expect {
        subject.load file_from_type 'well_formatted'
      }.not_to raise_error

      expect(subject[:foo] == :bar).to be_falsey
    end

    it 'reload should have no effect when no load has already been done' do
      expect( subject.reload).to be_nil
    end

    it 'should allow to reload when a load has already been done' do
      expect {subject.load file_from_type 'well_formatted'}.not_to raise_error
      expect {subject.reload}.not_to raise_error
    end


  end





end