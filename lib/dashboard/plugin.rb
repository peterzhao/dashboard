module Dashboard
  class Plugin
    class << self
      def register(id, plugin)
        @plugins ||= {}
        @plugins[id] = plugin
      end

      def check(id, options) 
        plugin(id).send :check, options
      end
      
      def template(id, options)
        plugin(id).send :template, options
      end

      def config(id, options)
        plugin(id).send :config, options
      end

      private 

      def plugin(id)
        raise "Could not find the plugin #{id}!" unless @plugins[id]
        @plugins[id].new
      end
    end
  end
end
