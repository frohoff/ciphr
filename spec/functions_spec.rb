require 'ciphr'

describe Ciphr::Functions do
  describe :setup do
    it "sets up the specified functions" do
        Ciphr::Functions.setup([Ciphr::Functions::Base2, Ciphr::Functions::Cat])
        Ciphr::Functions.functions.should == 
            [
                [Ciphr::Functions::Base2, [[["b2", "base2", "bin", "binary"], {}]]], 
                [Ciphr::Functions::Cat, [[["cat", "catenate"], {}]]]
            ]
        Ciphr::Functions.function_aliases.should == 
            {
                "b2"=>[Ciphr::Functions::Base2, {}], 
                "base2"=>[Ciphr::Functions::Base2, {}], 
                "bin"=>[Ciphr::Functions::Base2, {}], 
                "binary"=>[Ciphr::Functions::Base2, {}],                 
                "cat"=>[Ciphr::Functions::Cat, {}], 
                "catenate"=>[Ciphr::Functions::Cat, {}]
            }
    end
    it "sets up the automatically registered functions" do
        Ciphr::Functions.setup
        Ciphr::Functions.functions.should include(
            [Ciphr::Functions::Base2, [[["b2", "base2","bin","binary"], {}]]])
        Ciphr::Functions.functions.should include( 
            [Ciphr::Functions::Cat, [[["cat", "catenate"], {}]]])
    end
  end
end
