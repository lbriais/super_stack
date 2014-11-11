require 'yaml'

module SuperStack
  class Layer < Hash

    DEFAULT_LAYER_NAME = 'Unknown layer'

    attr_accessor :priority
    attr_reader :file_name

    def name=(name)
      @name = name.to_s
    end

    def name
      @name || DEFAULT_LAYER_NAME
    end

    def load(file_name, type = :yaml)
      load_from_yaml file_name if type == :yaml
      @file_name = file_name
    end

    private

    def load_from_yaml(file_name)
      Hash[YAML::load(open(file_name)).map { |k, v| [k.to_sym, v] }]
    end


  end
end