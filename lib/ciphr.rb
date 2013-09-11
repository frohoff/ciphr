require "ciphr/version"
require "openssl"
require "base64"
require "stringio"

module Ciphr
  FUNCTIONS = []

  module Function
    class Function
      def names
      end
    end

    class ReversibleFunction < Function

    end

    class Digest < Function

    end



    class Base < ReversibleFunction

    end

    class Base64 < Base

    end



    class Cipher < ReversibleFunction
      def initialize(cipher)
        @cipher = cipher
      end

      def apply(i,k)

      end
    end
  end

  class Stream
    def initialize(&reader)
      @reader = reader
      @buffer = ""
      @eof = false
    end

    def read(n)
      while @buffer.size < n && !@eof
        fill
      end
      if @buffer.size > 0
        ret = @buffer[0,n]
        @buffer = @buffer[n..-1] || ''
      else 
        ret = nil
      end
      ret
    end

    private
      def fill
        data = @reader.call
        @eof = true if !data
        @buffer = @buffer + data if data
      end
  end
end
