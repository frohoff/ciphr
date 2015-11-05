module Ciphr::Functions::Bitwise
	class BinaryTruncBitwise < Ciphr::Functions::Function
	  def apply
	    input,keyinput = @args
	    Proc.new do
	      keychunk = keyinput.read(256)
	      inchunk = input.read(256)
	      if inchunk && keychunk
	        a,b=[inchunk,keychunk].sort_by{|x| x.size}
	        a.bytes.each_with_index.map{|c,i|c.send(@options[:op], b.bytes.to_a[i%b.size])}.pack("c*")
	      else
	        nil
	      end
	    end
	  end

	  def self.variants
	    [
	      ['and-trunc', {:op=>:&}],
	      ['or-trunc', {:op=>:|}],
	      [['xor-trunc'], {:op=>:'^'}]
	    ]
	  end

	  def self.params
	    [:input, :input]
	  end
	end

	class BinaryBitwise < Ciphr::Functions::Function
	  def apply
	    input,keyinput = @args
            keyb, inputb = [keyinput.read.bytes.to_a, input.read.bytes.to_a].sort_by{|a| a.size }
	    Proc.new do
	      if inputb
	        resb = inputb.each_with_index.map{|c,i|c.send(@options[:op], keyb[i%keyb.size])}
                res = resb.pack("c*")
                inputb = nil
                res
	      else
	        nil
	      end
	    end
	  end

	  def self.variants
	    [
	      ['and', {:op=>:&}],
	      ['or', {:op=>:|}],
	      [['xor'], {:op=>:'^'}]
	    ]
	  end

	  def self.params
	    [:input, :input]
	  end
	end

	class UnaryBitwise < Ciphr::Functions::Function
	  def apply
	    input = @args[0]
	    Proc.new do
	      inchunk = input.read(1)
	      if inchunk
	        inchunk.bytes.map{|b| b = ~b }.pack("c*")
	      else
	        nil
	      end
	    end
	  end

	  def self.variants
	    [ ['not', {}] ]
	  end

	  def self.params
	    [:input]
	  end
	end
end
