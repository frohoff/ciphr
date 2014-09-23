module Ciphr
  class FunctionRegistry
    def initialize() 
      @function_classes = []
      @functions = []
      @function_aliases = {}
    end

    def register(klass)
      @function_classes << klass
    end

    def setup(classes=@function_classes)
      @functions = classes.map{|c| [c,c.variants]}.select{|a| a[1] && a[1].size > 0}.map{|a| 
                        [a[0], a[1].map{|v| [[v[0]].flatten.uniq, v[1]]}]}
      @function_aliases = Hash[@functions.map{|c,vs| vs.map{|v| [v[0]].flatten.map{|n| [n,[c, v[1]]]}}.flatten(1)}.flatten(1)]
    end

    def function_aliases
      @function_aliases
    end

    def [](name)
      @function_aliases[name] || (raise InvalidFunctionError.new(name))
    end

    def functions
      @functions
    end

    # http://stackoverflow.com/questions/746207/ruby-design-pattern-how-to-make-an-extensible-factory-class
    # global instance for load-time registration
    
    @@global = FunctionRegistry.new()

    def self.global
      @@global
    end

  end
end