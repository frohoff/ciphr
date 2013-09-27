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

    def self.[](name)
      @function_variants[name]
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

      def params
        []
      end

      def read(*args)
        @stream.read(*args)
      end
    end

    class InvertibleFunction < Function
      @invert = false
      attr_accessor :invert

      # def invert
      #   InvertedFunction.new(self)
      # end


      # class InvertedFunction < InvertibleFunction
      #   def initialize(f)
      #     super(nil,[])
      #     @f = f
      #   end

      #   def apply
      #     @f.unapply
      #   end

      #   def unapply
      #     @f.apply
      #   end
      # end      
    end

   OPENSSL_DIGESTS = %w(md2 md4 md5 sha sha1 sha224 sha256 sha384 sha512)

    class Digest < Function
      def self.variants
        OPENSSL_DIGESTS.map{|d| [d, {:variant => d}]}
      end

      def params
        [:input]
      end

      def apply
        input = args[0]
        digester = OpenSSL::Digest.new(@options[:variant])
        while chunk = input.read(256)
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
        OPENSSL_DIGESTS.map{|d| ["hmac#{d}", {:variant => d}]}        
      end

      def params 
        [:input, :key]
      end

      # reuse code from Digest.apply
      def apply
        input, key = @args
        digester = OpenSSL::HMAC.new(key.read, @options[:variant])
        while chunk = input.read(256)
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
        input = @args[0]
        if !invert
          Proc.new do
            chunk = input.read(3)
            chunk && ::Base64.encode64(chunk).gsub(/\s/,'')
          end
        else
          Proc.new do
            chunk = input.read(4)
            chunk && ::Base64.decode64(chunk)
          end
        end
      end

      # def unapply
      #   input = @args[0]        
      #   Proc.new do
      #     chunk = input.read(4)
      #     chunk && ::Base64.decode64(chunk)
      #   end
      # end

      def self.variants
        [[['b64','base64'], {}]]
      end

      def params 
        [:input]
      end
    end

    class Base16 < Base
      def self.variants
        [[['hex','b16','base16'], {}]]
      end

      def params
        [:arguments]
      end

      def apply
        input = @args[0]
        if !invert              
          Proc.new do
            chunk = input.read(1)
            chunk && chunk.unpack("H*")[0]
          end
        else
          Proc.new do
            chunk = input.read(2)
            chunk && [chunk].pack("H*")
          end
        end
      end

      # def unapply
      #   input = @args[0]
      #   Proc.new do
      #     chunk = input.read(2)
      #     chunk && [chunk].pack("H*")
      #   end
      # end
    end

    class Cipher < InvertibleFunction
      def apply
        input, key = @args
        cipher = OpenSSL::Cipher.new(@options[:variant])
        cipher.send(invert ? :decrypt : :encrypt)
        cipher.key = key.read
        Proc.new do
          chunk = input.read(256)
          if cipher
            if chunk
              cipher.update(chunk)
            else
              begin
                cipher.final
              ensure
                cipher = nil
              end
            end
          else
            nil
          end
        end
      end

      #TODO combine with encrypt/decrypt flag
      # def unapply
      #   input, key = @args
      #   cipher = OpenSSL::Cipher.new(@options[:variant])
      #   cipher.decrypt
      #   cipher.key = key.read
      #   Proc.new do
      #     chunk = @input.read(256)
      #     chunk ? cipher.update(chunk) : cipher.final
      #   end
      # end      

      def self.variants
        OpenSSL::Cipher.ciphers.map{|c| c.downcase}.uniq.map do |c|
          [c.gsub(/-/, ""), {:variant => c}]
        end
      end

      def params 
        [:input, :key]
      end
    end

    class XOR < Cipher
      def apply
        Proc.new do
          inchunk = @input.read(256)
          keychunk = @input.read(256) 
          #inchunk && keychunk && inchunk.size == keychunk.size && 
          # TODO
        end
      end

      # def unapply
      #   apply
      # end

      def self.variants
        [['xor', {}]]
      end

      def params
        [:input, :input]
      end
    end

    class StringReader < Function
      def apply
        StringProc.new(options[:string])
      end

      class StringProc #extend Proc?
        def initialize(str)
          @str = str
        end

        def call
          begin
            @str
          ensure
            @str = nil
          end
        end
      end      
    end

    class FileReader < Function
      def apply
        f = File.new(options[:filename], "r")
        Proc.new do
          chunk = f.read(256)
          f.clone if ! chunk
          chunk
        end
      end
    end


    class StdInReader < Function
      # def self.variants
      #   [['stdin',{}]]
      # end

      def apply
        Proc.new do
          $stdin.read(256)
        end
      end
    end


    #need streaming-capible impl before this is viable
    # class Regex < Function
    #   def apply
    #     Regex.new(options[:search])
    #   end
    # end
  end
end
