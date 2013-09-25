require 'openssl'
require 'base64'

module Ciphr
  module Functions

    # http://stackoverflow.com/questions/746207/ruby-design-pattern-how-to-make-an-extensible-factory-class

  	@function_classes = []
    @function_variants = {}

  	def self.register(klass)
      @function_classes << klass
  	end

    def self.setup
      class_variants = @function_classes.flat_map{|c| c.variants.map{|v| [c,v]}}
      @function_variants = Hash[class_variants.flat_map{|c,v| [v[0]].flatten.map{|n| [n,[c, v[1]]]}}]
    end

    class Function
    	def initialize(options, input)
    		@options = options
    		@input = input
    	end

      def self.variants
        []
      end

    	def self.inherited(subclass)
  		  Ciphr::Functions.register(subclass)
    	end
    end

    class InvertibleFunction < Function
      def invert
        InvertedFunction.new(self)
      end


      class InvertedFunction < InvertibleFunction
        def initialize(f)
          @f = f
        end

        def apply
          @f.unapply
        end

        def unapply
          @f.apply
        end
      end      
    end

   OPENSSL_DIGESTS = %w(md2 md4 md5 sha sha1 sha224 sha256 sha384 sha512)

    class Digest < Function
      def self.variants
        OPENSSL_DIGESTS.map{|d| [d, {:variant => d, :args => [:stream]}]}
      end

      def apply
        digester = OpenSSL::Digest.new(@options[:variant])
        while chunk = @input.read(256)
          digester.update(chunk)
        end
        digest = digester.digest
        Proc.new do
          d = digest
          digest = nil
          d
        end
      end
    end

    class HMAC < Digest
      def self.variants
        OPENSSL_DIGESTS.map{|d| ["hmac#{d}", {:variant => d, :args => [:stream, :stream]}]}        
      end

      def initialize(options, input, key)
        super(options, input)
        @key = key
      end

      # reuse code from Digest.apply
      def apply
        digester = OpenSSL::HMAC.new(@key, @options[:variant])
        while chunk = @input.read(256)
          digester.update(chunk)
        end
        digest = digester.digest
        Proc.new do
          d = digest
          digest = nil
          d
        end
      end
    end

    class Base < InvertibleFunction

    end

    class Base64 < Base
      def apply    
        Proc.new do
          chunk = @input.read(3)
          chunk && ::Base64.encode64(chunk)
        end
      end

      def unapply
        Proc.new do
          chunk = @input.read(4)
          chunk && ::Base64.decode64(chunk)
        end
      end

      def self.variants
        [['b64','base64'], {:args => [:stream]}]
      end
    end

    class Base16 < Base
      def self.variants
        [['hex','b16','base16'], {:args => [:stream]}]
      end

      def apply
        Proc.new do
          chunk = @input.read(1)
          chunk && chunk.each_byte.map { |b| b.to_s(16) }.join
        end
      end

      def unapply
        Proc.new do
          chunk = @input.read(2)
          chunk && chunk.scan(/../).map { |x| x.hex.chr }.join
        end
      end
    end

    class Cipher < InvertibleFunction
      def initialize(options, input, key)
        super(options, input)
        @key = key
      end

      def apply
        cipher = OpenSSL::Cipher.new(@options[:variant])
        cipher.encrypt
        cipher.key = @key.read(256)
        Proc.new do
          chunk = @input.read(256)
          chunk ? cipher.update(chunk) : cipher.final
        end
      end

      #TODO combine with encrypt/decrypt flag
      def unapply
        cipher = OpenSSL::Cipher.new(@options[:variant])
        cipher.decrypt
        cipher.key = @key.read(256)
        Proc.new do
          chunk = @input.read(256)
          chunk ? cipher.update(chunk) : cipher.final
        end
      end      

      def self.variants
        OpenSSL::Cipher.ciphers.map{|c| c.downcase}.uniq.map do |c|
          [c.gsub(/-/, ""), {:variant => c, :args => [:stream, :stream]}]
        end
      end
    end

  end
end
