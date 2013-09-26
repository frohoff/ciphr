module Ciphr
  class Stream
    def initialize(reader)
      @reader = reader
      @buffer = ""
      @eof = false
    end

    def read(n)
      init
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

      def init
        if @init
          @init = true
            @reader = @reader.apply if @reader.responds_to?(:apply)
        end
      end
  end

  class StringProc
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