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
	rule(:expression) { ( ( call | literal) >> ( str('|') >> ( call | literal ) ).repeat ).as(:segments) }

	root :expression
end


class CipherPreprocessor < Parslet::Transform
	rule(:segments => subtree(:segments)) {
		segs = [segments].flatten
		segs.unshift({:name => 'stdin', :invert => nil})
		if segs.size > 1 
			segs.inject{|m,o| puts o; o[:arguments] = [o[:arguments]||[]].flatten.unshift(m); o }
		end
		segs
	}
end

class CiphrTransformer < Parslet::Transform
	rule(:name => simple(:v)) { v }	
	rule(:string => simple(:v)) { Ciphr::Stream.new(Ciphr::StringProc.new(v)) }
	rule(:b64 => simple(:v)) { Ciphr::Functions::Base64.new({}, Ciphr::Stream.new(Ciphr::StringProc.new(v))) }
	rule(:b16 => simple(:v)) { Ciphr::Functions::Base16.new({}, Ciphr::Stream.new(Ciphr::StringProc.new(v))) }
	rule(:arguments => sequence(:arguments), :invert => simple(:invert), :name => simple(:name)) {|dict|
		name = dict[:name]
		klass, options = Ciphr::Functions[name.to_s]
		Ciphr::Stream.new(klass.new(options, *dict[:arguments]))
	}
	rule(:arguments => simple(:arguments), :invert => simple(:invert), :name => simple(:name)) {|dict|
		name = dict[:name]
		klass, options = Ciphr::Functions[name.to_s]
		Ciphr::Stream.new(klass.new(options, dict[:arguments]))
	}	
	rule(:invert => simple(:invert), :name => simple(:name)) {|dict|
		name = dict[:name]
		klass, options = Ciphr::Functions[name.to_s]
		Ciphr::Stream.new(klass.new(options))
	}		
end