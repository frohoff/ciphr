# strictly used by parser classes for literals/wiring
# TODO: disable registration

module Ciphr::Functions::Reader
  class StringReader < Ciphr::Functions::Function
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

  class FileReader < Ciphr::Functions::Function
    def apply
      f = File.open(options[:file], "r")
      Proc.new do
        chunk = f.read(256)
        f.close if ! chunk
        chunk
      end
    end
  end

  class IoReader < Ciphr::Functions::Function
    def apply
      input = args[0]
      Proc.new do
        input.read(256)
      end
    end
  end    
end
