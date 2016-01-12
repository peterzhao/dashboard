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
      
      def template(type, options)
        plugin(type, options).send :template
      end

      def style(type, options)
        plugin(type, options).send :style
      end

      def config(type)
        plugin(type).send :config
      end

      private 

      def plugin(type, options={})
        raise "Could not find the plugin #{type}!" unless @plugin_classes[type]
        @plugin_classes[type].new options
      end
    end
  end
end
