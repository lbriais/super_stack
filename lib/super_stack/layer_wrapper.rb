require 'yaml'

module SuperStack
  module LayerWrapper

    include Comparable
    include SuperStack::MergePolicies::PolicyHandler

    DEFAULT_LAYER_NAME = 'Unknown layer'

    attr_reader :file_name, :priority, :manager, :disabled
    attr_writer :source_auto_reload
    alias_method :disabled?, :disabled

    def priority=(priority)
      raise 'invalid priority' unless priority.is_a? Numeric
      @priority = priority
    end

    def source_auto_reload
      @source_auto_reload || false
    end

    def source_auto_reload?
      self.source_auto_reload
    end

    def enable_source_auto_reload
      self.source_auto_reload = true
    end

    def disable_source_auto_reload
      self.source_auto_reload = false
    end

    def name=(name)
      @name = name.to_s
    end

    def name
      @name || DEFAULT_LAYER_NAME
    end

    def load(file_name=self.file_name, type = :yaml)
      raise "Cannot read file '#{file_name}'" unless File.readable? file_name
      load_from_yaml file_name if type == :yaml
      self
    end

    def reload
      self.load if has_file?
    end

    def has_file?
      !@file_name.nil?
    end

    def <=>(other)
      # For priorities, the smallest the higher
      self.priority <=> other.priority
    end

    def inspect
      file_add_on = has_file? ? "file: '#{file_name}', " : ''
      priority_add_on = priority.nil? ? '' : "priority: #{priority}, "
      "{name: '#{name}', #{priority_add_on}#{file_add_on}#{super}}"
    end

    def to_s
      inspect
    end

    def self.from_hash(hash)
      class << hash; include SuperStack::LayerWrapper; end
      if SuperStack.compatibility_mode
        class << hash; include SuperStack::Compatibility::LayerWrapper; end
      end
    end

    def to_hash
      # Trick to return a bare hash
      {}.merge self
    end

    private


    def load_from_yaml(file_name)
      raw_content = File.read file_name
      res = YAML.load raw_content
      if res
        self.replace Hash[res.map { |k, v| [k, v] }]
      else
        raise "Invalid file content for '#{file_name}'" unless raw_content.empty?
        clear
      end
      @file_name = file_name
    end

  end
end