require 'yaml'

module SuperStack
  class Layer < Hash

    include Comparable

    DEFAULT_LAYER_NAME = 'Unknown layer'

    attr_accessor :priority
    attr_reader :file_name

    def priority=(priority)
      raise 'invalid priority' unless priority.is_a? Numeric
    end

    def name=(name)
      @name = name.to_s
    end

    def name
      @name || DEFAULT_LAYER_NAME
    end

    def load(file_name, type = :yaml)
      raise 'Invalid file' unless File.readable? file_name
      load_from_yaml file_name if type == :yaml
    end

    def loaded_from_file?
      !@file_name.nil?
    end

    def <=>(other)
      # For priorities, the smallest the higher
      self.priority <=> other.priority
    end

    def inspect
      "name: #{name}, priority: #{priority}, #{super}"

    end

    private

    def load_from_yaml(file_name)
      begin
        Hash[YAML::load(open(file_name)).map { |k, v| [k.to_sym, v] }]
      rescue  NoMethodError
        # Empty file...
      end
      @file_name = file_name
    end


  end
end