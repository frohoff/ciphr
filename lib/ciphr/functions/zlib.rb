require 'zlib'

module Ciphr::Functions::ZLib
  class Deflate < Ciphr::Functions::InvertibleFunction
    def apply
      input = @args[0]
      zstream = invert ? Zlib::Inflate.new : Zlib::Deflate.new
      Proc.new do
        chunk = input.read(256)
        if chunk
          if invert
            zstream.inflate(chunk)
          else
            zstream.deflate(chunk,Zlib::SYNC_FLUSH)
          end
        else
          begin
            #zstream.finish if invert
          ensure
            zstream.close
          end
        end
      end
    end

    def self.variants
      [
        [['deflate'], {}]
      ]
    end

    def self.params 
      [:input]
    end
  end


  class Gzip < Ciphr::Functions::InvertibleFunction
    class UncloseableIOProxy # hack to prevent GzipWriter from closing StringIO
      def initialize(delegate)
        @delegate = delegate
      end
      
      def method_missing(meth, *args, &block)
        if meth.to_s != "close"
          @delegate.send(meth, *args, &block)
        else
          nil
        end
      end
    end
    
    def apply
      input = @args[0]
      sio = StringIO.new
      gz = !invert ? Zlib::GzipWriter.new(UncloseableIOProxy.new(sio)) : Zlib::GzipReader.new(input) 
      Proc.new do
        if invert # unzip
          gz.read(256)
        else # zip
          chunk = input.read(256)
          if chunk
            gz.write chunk 
            sio.rewind
            ret = sio.read
            sio.rewind
            sio.truncate(0)
            ret
          elsif gz
            gz.close
            gz = nil
            sio.rewind
            ret = sio.read
            sio.rewind
            sio.truncate(0)
            ret
          else
            nil
          end
        end
      end
    end

    def self.variants
      [
        [['gzip','gz'], {}]
      ]
    end

    def self.params 
      [:input]
    end
  end
end
