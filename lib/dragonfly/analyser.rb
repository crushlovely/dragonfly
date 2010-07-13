module Dragonfly
  class Analyser < FunctionManager
    
    include Configurable
    configurable_attr :enable_cache, true
    
    def initialize
      super
      analyser = self
      @analysis_methods = Module.new do

        define_method :analyser do
          analyser
        end
        
      end
      @analysis_method_names = []
      @cache = {}
    end
    
    attr_reader :analysis_methods, :analysis_method_names
    
    def analyse(temp_object, method, *args)
      if enable_cache
        cache[[temp_object, method, *args]] ||= call_last(method, temp_object, *args)
      else
        call_last(method, temp_object, *args)
      end
    rescue NotDefined, UnableToHandle => e
      log.warn(e.message)
      nil
    end
    
    # Each time a function is registered with the analyser,
    # add a method to the analysis_methods module.
    # Expects the object that is extended to define 'analyse(method, *args)'
    def add(name, *args, &block)
      analysis_methods.module_eval %(
        def #{name}(*args)
          analyse(:#{name}, *args)
        end
      )
      analysis_method_names << name.to_sym
      super
    end
    
    def clear_cache!
      @cache = {}
    end
    
    private
    
    attr_reader :cache
    
  end
end
