
#require 'base32/crockford'
#require 'zbase32'

module Ciphr::Functions
  # http://stackoverflow.com/questions/746207/ruby-design-pattern-how-to-make-an-extensible-factory-class

  @function_classes = []
  @functions = []
  @function_aliases = {}

  def self.register(klass)
    @function_classes << klass
  end

  def self.setup(classes=@function_classes)
    @functions = classes.map{|c| [c,c.variants]}.select{|a| a[1] && a[1].size > 0}.map{|a| 
                      [a[0], a[1].map{|v| [[v[0]].flatten.uniq, v[1]]}]}
    @function_aliases = Hash[@functions.map{|c,vs| vs.map{|v| [v[0]].flatten.map{|n| [n,[c, v[1]]]}}.flatten(1)}.flatten(1)]
  end

  def self.function_aliases
    @function_aliases
  end

  def self.[](name)
    @function_aliases[name] || (raise InvalidFunctionError.new(name))
  end

  def self.functions
    @functions
  end

  class Function
    def initialize(options, args)
      @options = options
      @args = args
      @stream = Ciphr::Stream.new(self)
    end
    attr_accessor :options, :args #don't like that these are both writable, but c'est la vie

    def self.variants
      []
    end

    def self.inherited(subclass)
      Ciphr::Functions.register(subclass)
    end

    def self.params
      []
    end

    def self.invertable?
      false
    end
    
    def self.aligned
      nil
    end

    def read(*args)
      @stream.read(*args)
    end

    def prepend(*args)
      @stream.prepend(*args)
    end
  end

  class InvertibleFunction < Function
    @invert = false
    attr_accessor :invert   
    
    def self.invertable?
      true
    end 
  end
  
  class InvalidFunctionError < StandardError
    attr_reader :name
    def initialize(name)
      @name = name
    end
  end
end

require_relative 'functions/openssl'
require_relative 'functions/base_radix'
require_relative 'functions/zlib'
require_relative 'functions/bitwise'
require_relative 'functions/reader'
require_relative 'functions/url'
require_relative 'functions/simple'
require_relative 'functions/crypto'

