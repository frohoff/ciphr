require 'spec_helper'
require 'ciphr'

# considerations:
# invertable
# deterministic
# padded
# zero-input

describe Ciphr::Functions do
  r = Random.new(0) #deterministic
  tests = [""] + (1..50).map do |i|
    mag = r.rand(4)+1
    len = r.rand(10**mag)
    #len = (0.00001*r.rand(100000)**1.7).floor
    #$stderr.puts len
    r.bytes(len)
  end

  # temporarily disable randomization
  tests = [""," ", "\x00", "\x00 A"]
  
  Ciphr::FunctionRegistry.global.setup
  #TODO: run shorter/smaller tests first
  
  #TODO: decompose property tests into small, composable tests
  functions = Ciphr::FunctionRegistry.global.functions
  functions.find_all{|f| f[0].params.size == 1}.each do |f|
    f[1].each do |v|
      tests.each do |t|
        it "#{v[0][0]} #{t.inspect}" do
          result = Ciphr.transform(v[0][0],t)
          if f[0] != Ciphr::Functions::Simple::Cat && t != ""
            expect(result).not_to eq(t)
          end
          if f[0].invertable? && t != ""
            inv = Ciphr.transform("~" + v[0][0],result)
            #FIXME: need to enforce consistent encoding
            inv,t = [inv,t].map{|s| s.force_encoding('binary')}
            case f[0].aligned # FIXME: this is horrible
            when :left
              expect(inv).to start_with(t)
            when :right
              expect(t).to end_with(inv) # FIXME: horribly backwards
            else
              expect(inv).to eq(t)
            end
          end
        end
      end
    end
  end
end


