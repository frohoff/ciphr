module Ciphr::Functions
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
      f = File.open(options[:file], "r")
      Proc.new do
        chunk = f.read(256)
        f.close if ! chunk
        chunk
      end
    end
  end

  class StdInReader < Function
    def apply
      Proc.new do
        $stdin.read(256)
      end
    end
  end

  class IoReader < Function
    def apply
      input = args[0]
      Proc.new do
        input.read(256)
      end
    end
  end    
end