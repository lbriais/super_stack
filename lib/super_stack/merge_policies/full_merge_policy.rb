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
        deep_cloned_source = Marshal::load(Marshal.dump(h1))
        deep_cloned_source.extend DeepMergeWrapper
        deep_cloned_source.deep_merge! h2
      end

    end
  end
end