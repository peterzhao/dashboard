module Ju
  class Plugin

    def initialize(options)
      @options = options
    end

    def  options
      @options
    end

    class << self
      def register(type, plugin_class)
        @plugin_classes ||= {}
        @plugin_classes[type] = plugin_class
      end

      def types
        @plugin_classes.keys
      end

      def check(type, options) 
        plugin(type, options).send :check
      end

      def style(type, options)
        plugin(type, options).send :style
      end

      def config(type)
        name_attr = {
            'name' => 'name',
            'description' => 'Widget Name',
            'validate' => '^[0-9a-zA-Z\-_ ]+$',
            'validation_message' => 'Widget Name cannot be empty or contain special characters'
          }
        pull_inteval_attr = {
            'name' => 'pull_inteval',
            'description' => 'Pull Inteval',
            'validate' => '^[0-9]+$',
            'validation_message' => 'Pull Inteval must be digits',
            'default' => 5
          }
        config = plugin(type).send :config
        replace_attrs(config, name_attr, 0)
        replace_attrs(config, pull_inteval_attr, -1)
        config
      end

      private 

      def replace_attrs(config, attrs, position)
        name = attrs['name']
        old_one = config.find{|c| attrs['name'] == c['name']}
        config.delete(old_one) if old_one
        config.insert(position, attrs)
      end

      def plugin(type, options={})
        raise "Could not find the plugin #{type}!" unless @plugin_classes[type]
        @plugin_classes[type].new options
      end
    end
  end
end
