module SuperStack
  class Manager

    include SuperStack::MergePolicies::PolicyHandler
    alias_method :default_merge_policy, :merge_policy
    alias_method :'default_merge_policy=', :'merge_policy='

    DEFAULT_PRIORITY_INTERVAL = 10
    DEFAULT_MERGE_POLICY = SuperStack::MergePolicies::StandardMergePolicy

    attr_reader :layers

    def initialize
      @layers = {}
      self.default_merge_policy = DEFAULT_MERGE_POLICY
    end

    def [](filter=nil)
      layers = to_a
      return [] if layers.empty?
      return layers[0] if layers.count == 1
      first_layer = layers.shift
      res = layers.inject(first_layer) do |stack, layer|
        policy_to_apply = layer.merge_policy.nil? ? default_merge_policy : layer.merge_policy
        policy_to_apply.merge stack, layer
      end
      if filter.nil?
        res
      else
        res[filter]
      end
    end

    def to_a
      layers.values.sort
    end

    def add_layer(layer)
      if layer.is_a? Hash and not layer.class.included_modules.include? SuperStack::LayerWrapper
        SuperStack::LayerWrapper.from_hash layer
      end
      set_valid_name_for layer if layers.keys.include? layer.name
      layer.priority = get_unused_priority if layer.priority.nil?
      layers[layer.name] = layer
    end

    def <<(layer)
      add_layer layer
    end

    def reload_layers
      layers.values.each &:reload
    end

    private

    def get_unused_priority
      ordered = self.to_a
      return DEFAULT_PRIORITY_INTERVAL if ordered.empty?
      ordered.last.priority + DEFAULT_PRIORITY_INTERVAL
    end

    def set_valid_name_for(layer)
      name_pattern = /^(?<layer_name>.+) #(?<number>\d+)\s*$/
      while layers.keys.include? layer.name
        layer.name = "#{layer.name} #1" unless layer.name =~ name_pattern
        layer.name.match(name_pattern) do |md|
          layer.name = "#{md[:layer_name]} ##{md[:number].to_i + 1}"
          next
        end
      end
      layer.name
    end

  end
end