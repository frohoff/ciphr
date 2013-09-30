module Ciphr
  class Stream
    def initialize(reader)
      @reader = reader
      @buffer = ""
      @eof = false
    end

    def read(n=2**(8*4)) #fix this
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

      def init #hack
        if !@init
          @init = true
          @reader = @reader.apply if @reader.respond_to?(:apply)
        end
      end
  end
end