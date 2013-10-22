module Ciphr
  class Stream
    def initialize(reader)
      @reader = reader
      @buffer = ""
      @eof = false
    end

    def read(n=nil) #fix this
      if n
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
      else
        buff = ""
        while chunk=read(256)
          buff+=chunk
        end
        buff 
      end
    end

    def prepend(str)
      @buffer = str + @buffer
    end

    private
      def fill
        data = @reader.call
        @eof = true if !data
        @buffer = @buffer + data if data
      end

      def init #hack
        if !@init
          @init = true
          @reader = @reader.apply if @reader.respond_to?(:apply)
        end
      end
  end
end
