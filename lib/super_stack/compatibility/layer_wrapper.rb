module SuperStack
  module Compatibility

    module LayerWrapper

      private

      def load_from_yaml(file_name)
        begin
          self.replace Hash[YAML::load(File.open(file_name)).map { |k, v| [k.to_s, v] }]
        rescue  NoMethodError => e
          # Empty file...
          raise "Invalid file '#{file_name}'" unless e.message =~ /false:FalseClass/
        end
        @file_name = file_name
      end

    end

  end

end

