module SuperStack
  module MergePolicies
    module FullMergePolicy

      def self.merge(h1, h2)
      end

      def self.__merge(h1, h2)
        merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : [:undefined, nil, :nil].include?(v2) ? v1 : v2 }
        h1.merge(h2, &merger)
      end


    end
  end
end