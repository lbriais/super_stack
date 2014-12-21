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
        if h1.respond_to? :manager
          saved_manager = h1.manager
          h1.instance_variable_set :@manager, nil
        end

        begin
          deep_cloned_source = Marshal::load(Marshal.dump(h1))
        ensure
          h1.instance_variable_set :@manager, saved_manager if h1.respond_to? :manager
        end
        deep_cloned_source.extend DeepMergeWrapper
        deep_cloned_source.deep_merge! h2

      end

    end
  end
end