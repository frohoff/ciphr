require 'spec_helper'
require 'ciphr'

describe Ciphr::FunctionRegistry do
  describe :setup do
    it "sets up the specified functions" do
        Ciphr::FunctionRegistry.global.setup([Ciphr::Functions::Base::Base2, Ciphr::Functions::Simple::Cat])
        Ciphr::FunctionRegistry.global.functions.should == 
            [
                [Ciphr::Functions::Base::Base2, [[["b2", "base2", "bin", "binary"], {}]]], 
                [Ciphr::Functions::Simple::Cat, [[["cat", "catenate"], {}]]]
            ]
        Ciphr::FunctionRegistry.global.function_aliases.should == 
            {
                "b2"=>[Ciphr::Functions::Base::Base2, {}], 
                "base2"=>[Ciphr::Functions::Base::Base2, {}], 
                "bin"=>[Ciphr::Functions::Base::Base2, {}], 
                "binary"=>[Ciphr::Functions::Base::Base2, {}],                 
                "cat"=>[Ciphr::Functions::Simple::Cat, {}], 
                "catenate"=>[Ciphr::Functions::Simple::Cat, {}]
            }
    end
    it "sets up the automatically registered functions" do
        Ciphr::FunctionRegistry.global.setup
        Ciphr::FunctionRegistry.global.functions.should include(
            [Ciphr::Functions::Base::Base2, [[["b2", "base2","bin","binary"], {}]]])
        Ciphr::FunctionRegistry.global.functions.should include( 
            [Ciphr::Functions::Simple::Cat, [[["cat", "catenate"], {}]]])
    end
  end
end
