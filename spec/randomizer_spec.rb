require 'ciphr'

# considerations:
# invertable
# deterministic
# padded
# zero-input

describe Ciphr::Functions do
  r = Random.new(0) #deterministic
  tests = [""] + (1..10).map do |i|
    r.bytes(r.rand(1000))
  end
  
  Ciphr::Functions.setup
  
  functions = Ciphr::Functions.functions
  functions.find_all{|f| f[0].params.size == 1}.each do |f|
    f[1].each do |v|
      tests.each do |t|
        it "#{v[0][0]} #{t.inspect}" do
          result = Ciphr.transform(v[0][0],t)
          if f[0] != Ciphr::Functions::Cat && t != ""
            expect(result).not_to eq(t)
          end
          if f[0].invertable? && t != ""
            inv = Ciphr.transform("~" + v[0][0],result)
            #FIXME: need to enforce consistent encoding
            inv,t = [inv.force_encoding('binary'), t.force_encoding('binary')]
            if f[0].padding? #for left-aligned, right-padded base functions
              expect(inv).to start_with(t)  
            else
              expect(inv).to eq(t)
            end
          end
        end
      end
    end
  end
end


