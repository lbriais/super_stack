module SuperStack
  class Manager

    DEFAULT_INTERVAL = 10

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
      layer.priority = get_unused_priority if layer.priority.nil?
      layers[layer.name] = layer
    end

    private

    def get_unused_priority
      ordered = self.to_a
      return DEFAULT_INTERVAL if ordered.empty?
      ordered.last.priority + DEFAULT_INTERVAL
    end

  end
end