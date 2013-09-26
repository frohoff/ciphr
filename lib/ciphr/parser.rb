require 'parslet'
require 'pp'

class CiphrParser < Parslet::Parser

	rule(:spaces)      { match('\s').repeat(1) }
	rule(:spaces?)     { spaces.maybe }

	rule(:name) { (match('[a-z]') >> match('[a-z0-9]').repeat).as(:name) }	
	rule(:literal) { (b16 | b64 | string | file) }
	rule(:file) { str('@') >> (	string | match('[^ ()\[\]{},|]' ).repeat ).as(:file) } 
	rule(:string) { str('"') >> ( str('\\') >> any | str('"').absent? >> any ).repeat.as(:string) >> str('"') }
	rule(:b16) { str('0x') >> match('[0-9a-f]').repeat(1).as(:b16) }
	rule(:b64) { str('=') >> match('[0-9a-zA-Z+/=]').repeat(1).as(:b64) }
	rule(:call) { str('~').maybe.as(:invert) >> name.as(:name) >> (str('(') >> (expression >> (str(',') >> expression).repeat).maybe.as(:arguments) >> str(')')).maybe }
	rule(:expression) { ( ( call | literal) >> ( str('|') >> ( call | literal ) ).repeat ).as(:operations) }

	root :expression
end


class CipherPreprocessor < Parslet::Transform
	rule(:operations => subtree(:operations)) {
		segs = [operations].flatten
		segs.unshift({:name => 'stdin', :invert => nil})
		if segs.size > 1 
			segs.inject{|m,o| puts o; o[:arguments] = [o[:arguments]||[]].flatten.unshift(m); o }
		end
		segs
	}
end

class CiphrTransformer < Parslet::Transform
	def self.stream(f) 
		Ciphr::Stream.new(f)
	end

	#def self.partition_by_args
	#end
	rule(:name => simple(:v)) { v }	
	rule(:string => simple(:v)) {|d| Ciphr::Functions::StringReader.new({:string => d[:v]},[]) }
	rule(:b64 => simple(:v)) {|d| Ciphr::Functions::Base64.new({}, [Ciphr::Functions::StringReader.new({:string => d[:v]},[])]).invert }
	rule(:b16 => simple(:v)) {|d| Ciphr::Functions::Base16.new({}, [Ciphr::Functions::StringReader.new({:string => d[:v]},[])]).invert }
	rule(:arguments => sequence(:arguments), :invert => simple(:invert), :name => simple(:name)) {|d|
		klass, options = Ciphr::Functions[d[:name].to_s]
		f = klass.new(options, dict[:arguments])
		f = f.invert if d[:invert]
		f
	}
	rule(:arguments => simple(:arguments), :invert => simple(:invert), :name => simple(:name)) {|d|
		klass, options = Ciphr::Functions[d[:name].to_s]
		f = klass.new(options, dict[:arguments])
		f = f.invert if d[:invert]
		f
	}	
	rule(:invert => simple(:invert), :name => simple(:name)) {|d|
		klass, options = Ciphr::Functions[d[:name].to_s]
		f = klass.new(options, [])
		f = f.invert if d[:invert]
		f
	}	
	rule(:operations => simple(:operation)) { operation }	
	rule(:operations => sequence(:operations)) {|d|  
		d[:operations].inject{|m,f| f.args = [f.args||[]].flatten.unshift(m); f }
	}	
end