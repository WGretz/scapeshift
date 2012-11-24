require 'active_support/cache'
require 'active_support/cache/null_store'

module Scapeshift
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end
  end

  class Configuration
    attr_accessor :cache

    def initialize
      self.cache = :memory_store
    end

    def cache=(*store_option)
      @cache = ActiveSupport::Cache.lookup_store(*store_option)
    end
  end
end
