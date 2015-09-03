require "configliere"

module Bookbag
  module Settings
    class << self
      def config
        unless @config
          @config = ::Configliere::Param.new
          @config.read File.join File.expand_path('..', __FILE__), "defaults.config.yml"
          @config.resolve!
        end
        @config
      end

      def [](key)
        config[key]
      end

      def []=(key,value)
        config[key] = value
      end
    end

  end
end
