require 'yaml'

module SuperStack
  module LayerWrapper

    include Comparable
    include SuperStack::MergePolicies::PolicyHandler

    DEFAULT_LAYER_NAME = 'Unknown layer'

    attr_reader :file_name, :priority

    def priority=(priority)
      raise 'invalid priority' unless priority.is_a? Numeric
      @priority = priority
    end

    def name=(name)
      @name = name.to_s
    end

    def name
      @name || DEFAULT_LAYER_NAME
    end

    def load(file_name, type = :yaml)
      raise "Cannot read file '#{file_name}'" unless File.readable? file_name
      load_from_yaml file_name if type == :yaml
      self
    end

    def has_file?
      !@file_name.nil?
    end

    def <=>(other)
      # For priorities, the smallest the higher
      self.priority <=> other.priority
    end

    def inspect
      file_add_on = has_file? ? "file: '#{file_name}', " : ''
      priority_add_on = priority.nil? ? '' : "priority: #{priority}, "
      "{name: '#{name}', #{priority_add_on}#{file_add_on}#{super}}"
    end

    def to_s
      inspect
    end

    private

    def load_from_yaml(file_name)
      begin
        self.replace Hash[YAML::load(File.open(file_name)).map { |k, v| [k.to_sym, v] }]

      rescue  NoMethodError => e
        # Empty file...
        raise "Invalid file '#{file_name}'" unless e.message =~ /false:FalseClass/
      end
      @file_name = file_name
    end

  end
end