module SuperStack
  class Manager

    DEFAULT_INTERVAL = 10

    attr_reader :layers, :merge_policy

    def [](filter=nil)
      raise 'Manager not ready (no merge policy specified)' unless ready?
      layers = to_a
      return [] if layers.empty?
      return layers[0] if layers.count == 1
      first_layer = layers.shift
      res = layers.inject(first_layer) do |stack, layer|
        merge_policy.merge stack, layer
      end
      if filter.nil?
        res
      else
        res[filter]
      end
    end

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

    def merge_policy=(policy)
      raise "Invalid merge policy #{policy}" unless SuperStack::MergePolicies.list.include? policy
      @merge_policy = policy
    end

    def ready?
      !@merge_policy.nil?
    end

    private

    def get_unused_priority
      ordered = self.to_a
      return DEFAULT_INTERVAL if ordered.empty?
      ordered.last.priority + DEFAULT_INTERVAL
    end

  end
end