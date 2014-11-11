module SuperStack
  class Manager

    attr_reader :layers

    def initialize
      @layers = {}
    end

    def to_a
      layers.values.sort
    end

    def add_layer(layer)
      raise 'Layer should have a name' unless layer.respond_to? :name
      raise 'Layer already existing' if layers.keys.include? layer.name
      layers[layer.name] = layer
    end

  end
end