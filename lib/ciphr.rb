require "ciphr/version"
require "ciphr/functions"
require "ciphr/stream"
require "ciphr/parser"

module Ciphr
	@@init = false

	def self.init()
		@@init = true
		Ciphr::FunctionRegistry.global.setup
	end 

	def self.transform(spec, input = STDIN, output = STDOUT)
		init if !@@init
		if input.is_a? String
			input = StringIO.new(input)
			input.close_write
			output = StringIO.new()
		end

        parsed = Ciphr::Parser.new.parse(spec)
        transformed = Ciphr::Transformer.new(input).apply(parsed)
     
        while chunk = transformed.read(256)
          output.write chunk
        end	

        if output.is_a? StringIO
        	output.string
        else
        	nil
        end
	end	
end
