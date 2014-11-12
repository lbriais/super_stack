require 'super_stack/merge_policies/override_policy'


module SuperStack
  module MergePolicies

    def self.list
      constants.map(&:to_s).grep(/Policy$/).map{|policy_name| const_get policy_name}
    end

  end
end