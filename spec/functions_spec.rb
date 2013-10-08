require 'ciphr'

describe Ciphr::Functions do
  describe :setup do
  	it "sets up the specified functions" do
    	Ciphr::Functions.setup([Ciphr::Functions::Base64, Ciphr::Functions::Cat])
    	Ciphr::Functions.functions.should == 
    		[
    			[Ciphr::Functions::Base64, [[["b64", "base64"], {}]]], 
    			[Ciphr::Functions::Cat, [[["cat", "noop"], {}]]]
    		]
    	Ciphr::Functions.function_aliases.should == 
    		{
				"b64"=>[Ciphr::Functions::Base64, {}], 
				"base64"=>[Ciphr::Functions::Base64, {}], 
				"cat"=>[Ciphr::Functions::Cat, {}], 
				"noop"=>[Ciphr::Functions::Cat, {}]
    		}
  	end
  	it "sets up the automatically registered functions" do
    	Ciphr::Functions.setup
    	Ciphr::Functions.functions.should include(
    		[Ciphr::Functions::Base64, [[["b64", "base64"], {}]]])
    	Ciphr::Functions.functions.should include( 
    		[Ciphr::Functions::Cat, [[["cat", "noop"], {}]]])
  	end
  end
end
