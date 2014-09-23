
#require 'base32/crockford'
#require 'zbase32'
require_relative 'function_registry'

module Ciphr::Functions
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
      Ciphr::FunctionRegistry.global.register(subclass)
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
end

require_relative 'functions/openssl'
require_relative 'functions/base_radix'
require_relative 'functions/zlib'
require_relative 'functions/bitwise'
require_relative 'functions/reader'
require_relative 'functions/url'
require_relative 'functions/simple'
require_relative 'functions/crypto'

