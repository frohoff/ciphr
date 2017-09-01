module Ciphr::Functions::Bitwise
	class Rot13 < Ciphr::Functions::Function
	  def apply
	    input = @args[0]
	    Proc.new do
	      inchunk = input.read(256)
	      if inchunk 
				  inchunk.tr("A-Za-z", "N-ZA-Mn-za-m")
	      else
	        nil
	      end
	    end
	  end

	  def self.variants
	    [
	      ['rot13', {}]
	    ]
	  end

	  def self.params
	    [:input]
	  end
	end
end
