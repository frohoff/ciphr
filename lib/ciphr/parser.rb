require 'parslet'
require 'pp'

class Mini < Parslet::Parser

	#rule(:space)      { match('\s').repeat(1) }
	#rule(:space?)     { space.maybe }

	rule(:name)    { match('[a-z]') >> match('[a-z0-9]').repeat }

	rule(:literal) { (b16 | b64 | string) }
	rule(:string) { str('"') >> (
        str('\\') >> any | str('"').absent? >> any
      ).repeat.as(:value) >> str('"') }
	rule(:b16) { str('0x') >> match('[0-9a-f]').repeat.as(:value) }
	rule(:b64) { str('=') >> match('[0-9a-zA-Z+/=]').repeat.as(:value) }
	rule(:arguments) { expression >> (str(',') >> arguments).repeat }
	rule(:call) { str('~').maybe.as(:invert) >> name >> (str('(') >> arguments.maybe.as(:arguments) >> str(')')).maybe }
	rule(:pipes) { (call | literal) >> (str('|') >> pipes).repeat }

	rule(:expression) { pipes }

	root :expression
end