require 'super_stack/version'
require 'super_stack/merge_policies'
require 'super_stack/layer_wrapper'
require 'super_stack/layer'
require 'super_stack/manager'

module SuperStack

  def self.set_compatibility_mode
    require 'super_stack/compatibility/layer_wrapper'
    require 'super_stack/compatibility/manager'

    SuperStack::Manager.class_eval do
      include SuperStack::Compatibility::Manager
    end

    SuperStack::LayerWrapper.module_eval do
      include SuperStack::Compatibility::LayerWrapper
    end
  end

end