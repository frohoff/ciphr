module Ciphr::Functions::Simple
  class Cat < Ciphr::Functions::Function
    def self.variants
      [[['cat','catenate'], {}]]
    end

    def self.params
      [:input]
    end

    def apply
      inputs = @args
      i = 0
      chunk = nil
      Proc.new do
        chunk = inputs[i].read(256)
        if ! chunk
          i += 1
          chunk = inputs[i] && inputs[i].read(256)
        end
        #while !(chunk = inputs[i].read(256)) && i < inputs.size
        #  i++
        #end 
        chunk
      end
    end
  end 

  class Repack < Ciphr::Functions::Function
    def apply
      input, ch1in, ch2in = @args
      content, ch1, ch2 = [input.read, ch1in.read, ch2in.read]
      Proc.new do
        if content
          begin
            content.unpack(ch1).pack(ch2)
          ensure
            content = nil
          end
        else
          nil
        end
      end
    end

    def self.variants
      [ [['repack'], {}] ]
    end

    def self.params
      [:input,:ch1,:ch2]
    end
  end

  class Translate < Ciphr::Functions::Function
    def apply
      input, ch1in, ch2in = @args
      ch1, ch2 = [ch1in.read, ch2in.read]
      Proc.new do
        inchunk = input.read(1)
        if inchunk
          inchunk.tr(ch1, ch2)
        else
          nil
        end
      end
    end

    def self.variants
      [ [['tr','translate'], {}] ]
    end

    def self.params
      [:input,:ch1,:ch2]
    end
  end

  class Replace < Ciphr::Functions::Function
    def apply
      input, searchin, replacein = @args
      search, replace = [searchin.read, replacein.read]
      buf = ""
      Proc.new do
        if buf.size == search.size && search.size > 0
          buf = ""
          replace
        else
          inchunk = input.read(1)
          if inchunk 
            if inchunk == search[buf.size]
              buf += inchunk
              ""
            else
              buf += inchunk
              input.prepend(buf[1,buf.size])
              ret = buf[0]
              buf = ""
              ret
            end
          else
            if buf.size > 0
              ret = buf
              buf = ""
              ret
            else
              nil
            end
          end
        end
      end
    end

    def self.variants
      [ [['repl','replace'], {}] ]
    end

    def self.params
      [:input,:search,:replace]
    end
  end
end
