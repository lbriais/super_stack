require 'deep_merge/core'

module SuperStack
  module MergePolicies
    module FullMergePolicy

      module DeepMergeWrapper
        def deep_merge!(source)
          DeepMerge::deep_merge!(source, self, {})
        end
      end

      def self.merge(h1, h2)
        h1.extend DeepMergeWrapper
        h1.deep_merge! h2
      end

      def self.__merge(h1, h2)
        merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : [:undefined, nil, :nil].include?(v2) ? v1 : v2 }
        h1.merge(h2, &merger)
      end


    end
  end
end