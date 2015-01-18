module SuperStack
  class Manager

    include SuperStack::MergePolicies::PolicyHandler
    alias_method :default_merge_policy, :merge_policy
    alias_method :'default_merge_policy=', :'merge_policy='

    DEFAULT_PRIORITY_INTERVAL = 10
    DEFAULT_MERGE_POLICY = SuperStack::MergePolicies::StandardMergePolicy

    attr_reader :layers, :write_layer

    def initialize
      @layers = {}
      self.default_merge_policy = DEFAULT_MERGE_POLICY
    end

    def write_layer=(layer_or_layer_name)
      layer = get_existing_layer layer_or_layer_name, 'Invalid write layer'
      @previous_write_layer = nil
      @write_layer = layer
    end

    def []=(key,value)
      raise 'No write layer specified' if write_layer.nil?
      write_layer[key] = value
    end

    def [](filter=nil)
      layers = to_a
      return [] if layers.empty?
      return layers[0] if layers.count == 1
      first_layer = layers.shift
      res = layers.inject(first_layer) do |stack, layer|
        if layer.disabled?
          stack
        else
          policy_to_apply = layer.merge_policy.nil? ? default_merge_policy : layer.merge_policy
          policy_to_apply.merge stack, layer
        end
      end
      if filter.nil?
        # Trick to return a bare hash
        {}.merge res
      else
        res[filter]
      end
    end

    def to_a
      layers.values.sort
    end

    def reset
      write_layer.clear unless write_layer.nil?
    end

    def add_layer(layer)
      if layer.is_a? Hash and not layer.class.included_modules.include? SuperStack::LayerWrapper
        SuperStack::LayerWrapper.from_hash layer
      end
      set_valid_name_for layer if layers.keys.include? layer.name
      layer.priority = get_unused_priority if layer.priority.nil?
      raise 'This layer already belongs to a manager' unless layer.manager.nil?
      layers[layer.name] = layer
      layer.instance_variable_set :@manager, self
      layer.managed if layer.respond_to? :managed
    end

    def remove_layer(layer_or_layer_name)
      layer = get_existing_layer layer_or_layer_name, 'Cannot remove unmanaged layer'
      layer_name = layer.name
      @write_layer = nil if layer == write_layer
      layers.delete layer_name
    end

    def disable_layer(layer_or_layer_name)
      layer = get_existing_layer layer_or_layer_name, 'Cannot disable unmanaged layer'
      if layer == write_layer
        @previous_write_layer = write_layer
        @write_layer = nil
      end
      layer.instance_variable_set :@disabled, true
    end

    def enable_layer(layer_or_layer_name)
      layer = get_existing_layer layer_or_layer_name, 'Cannot enable unmanaged layer'
      layer.instance_variable_set :@disabled, false
      @write_layer = @previous_write_layer if layer == @previous_write_layer
    end

    def <<(layer)
      add_layer layer
    end

    def reload_layers
      layers.values.each &:reload
    end

    private

    def get_existing_layer(layer_or_layer_name, error_message)
      layer_name = layer_or_layer_name.to_s if layer_or_layer_name.is_a? Symbol
      layer_name = layer_or_layer_name if layer_or_layer_name.is_a? String
      layer = layers[layer_name] unless layer_name.nil?
      layer = layer_or_layer_name if layer_or_layer_name.class.included_modules.include? SuperStack::LayerWrapper
      raise error_message if layer.nil?
      layer
    end

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