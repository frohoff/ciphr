module Ciphr
  module Functions
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
end
