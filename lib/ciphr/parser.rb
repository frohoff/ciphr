require 'parslet'

class Ciphr::Parser < Parslet::Parser
    def pad(&p)
        spaces? >> p.call >> spaces?
    end

    def wrapstr(d)
        str(d) >> ( str('\\') >> any | str(d).absent? >> any ).repeat.maybe.as(:string) >> str(d)
    end

    def wrapbraces(bs,&p)
        exp = str('')
        bs.each{|b|
            exp = ( str(b[0]) >> p.call >> str(b[1]) ) | exp
        }
        exp
    end

    rule(:spaces)      { match('\s').repeat(1) }
    rule(:spaces?)     { spaces.maybe }
    rule(:name) { (match('[a-z]') >> match('[a-z0-9\-_]').repeat).as(:name) }
    rule(:literal) { pad { b2 | b8 | b10 | b16 | b64 | string | file } } 
    rule(:file) { str('@') >> spaces? >> ( string | match('[^ ()\[\]{},|]' ).repeat ).as(:file) }
    rule(:string) { wrapstr("'") | wrapstr('"') }
    rule(:b2) { str('0b') >> match('[0-1]').repeat(1).as(:b2) }
    rule(:b8) { ( match('0').repeat(1) >> match('o').maybe >> match('[0-7]').repeat(1).as(:b8) ) }
    rule(:b10) { ( match('[1-9]') >> match('[0-9]').repeat ).as(:b10) }
    rule(:b16) { str('0x') >> match('[0-9a-fA-F]').repeat(1).as(:b16) }
    rule(:b64) { str('=') >> match('[0-9a-zA-Z+/=]').repeat(1).as(:b64) }
    rule(:call) { pad { match('[~!^]').maybe.as(:invert) } >> pad { name.as(:name) } >> pad { wrapbraces(['()','[]','{}']) { pad { (expression >> (str(',') >> expression).repeat).maybe.as(:arguments) } }.maybe } }
    rule(:expression) { ( ( call | literal ) >> ( str('|') | str(' ').repeat >> ( call | literal ) ).repeat ).as(:operations) }
    root :expression
end

class Ciphr::Transformer < Parslet::Transform
    def initialize(input)
        super()
        @input = input

        #in ctor to provide instance scope to rule blocks
        rule(:name => simple(:v)) { v } 
        rule(:file => simple(:v)) {|d| Ciphr::Functions::Reader::FileReader.new({:file => d[:v].to_s}, [])}
        #eagerly eval these?
        #trim to nearest byte vs chunk?
        rule(:string => simple(:v)) {|d| Ciphr::Functions::Reader::StringReader.new({:string => d[:v]},[]) }
        rule(:b2 => simple(:v)) {|d| Ciphr::Functions::Base::Base2.new({:radix => 2}, [Ciphr::Functions::Reader::StringReader.new({:string => lpad(d[:v].to_s,8,"0")},[])]).tap{|f| f.invert = true} }
        rule(:b8 => simple(:v)) {|d| Ciphr::Functions::Base::Base8.new({:radix => 8}, [Ciphr::Functions::Reader::StringReader.new({:string => lpad(d[:v].to_s,8,"0")},[])]).tap{|f| f.invert = true} }
        rule(:b10 => simple(:v)) {|d| Ciphr::Functions::Radix::Radix.new({:radix => 10}, [Ciphr::Functions::Reader::StringReader.new({:string => d[:v].to_s},[])]).tap{|f| f.invert = true} }
        rule(:b16 => simple(:v)) {|d| Ciphr::Functions::Base::Base16.new({:radix => 16}, [Ciphr::Functions::Reader::StringReader.new({:string => lpad(d[:v].to_s,2,"0")},[])]).tap{|f| f.invert = true} }
        rule(:b64 => simple(:v)) {|d| Ciphr::Functions::Base::Base64.new({:chars => "+/="}, [Ciphr::Functions::Reader::StringReader.new({:string => d[:v]},[])]).tap{|f| f.invert = true} }
        rule(:arguments => sequence(:arguments), :invert => simple(:invert), :name => simple(:name)) {|d| transform_call(d) }
        rule(:arguments => simple(:arguments), :invert => simple(:invert), :name => simple(:name)) {|d| transform_call(d) }
        rule(:invert => simple(:invert), :name => simple(:name)) {|d| transform_call(d) }
        rule(:operations => simple(:operations)) {|d| transform_operations(d)}
        rule(:operations => sequence(:operations)) {|d| transform_operations(d)}    
    end

    def lpad(s,n,p)
        s.size % n == 0 ? s : p * (n - s.size % n) + s
    end

    def transform_operations(d)
        operations = [d[:operations]].flatten
        if operations[0].args.size < operations[0].class.params.size
            operations.unshift(Ciphr::Functions::Reader::IoReader.new({},[@input]))
        end
        operations.inject{|m,f| f.args = [f.args||[]].flatten.unshift(m); f }
    end

    def transform_call(d)
        klass, options = Ciphr::FunctionRegistry.global[d[:name].to_s]
        f = klass.new(options, [d[:arguments]||[]].flatten)
        f.invert = true if d[:invert]
        f
    end
end
