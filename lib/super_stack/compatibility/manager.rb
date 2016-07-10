module SuperStack
  module Compatibility

    module Manager

      def []=(key,value)
        raise 'No write layer specified' if write_layer.nil?
        write_layer[key.to_s] = value
      end

      def [](filter=nil)
        layers = to_a
        return [] if layers.empty?
        layers.each { |layer| layer.reload if layer.source_auto_reload?}
        first_layer = layers.shift
        first_layer = first_layer.disabled? ? SuperStack::Layer.new : first_layer
        res = layers.inject(first_layer) do |stack, layer|
          if layer.disabled?
            stack
          else
            policy_to_apply = layer.merge_policy.nil? ? default_merge_policy : layer.merge_policy
            policy_to_apply.merge stack, stringify_keys(layer)
          end
        end
        if filter.nil?
          res.to_hash
        else
          res[filter]
        end
      end



      private

      def stringify_keys(hash)
        hash.inject({}){|stringified_hash, (key, value)|
          stringified_hash[key.to_s] = value
          stringified_hash
        }
      end

    end

  end
end