require 'spec_helper'
require 'ciphr'

describe Ciphr do
  describe :transform do
    it "works for some simple test cases" do
        Ciphr.transform("md5 hex","").should be == "d41d8cd98f00b204e9800998ecf8427e"
        Ciphr.transform("b64 ~b64","foobar").should be == "foobar"
        Ciphr.transform("b2 b16 ~b16 ~b2","foobar").should be == "foobar"
        Ciphr.transform('"foobar"',"").should be == "foobar"
        Ciphr.transform('=ABBB b64',"").should be == "ABBB"        
        Ciphr.transform('0x41',"").should be == "A"
        Ciphr.transform('0b01000001',"").should be == "A"
        Ciphr.transform('0x43 xor[0x01]',"").should be == "B"
        Ciphr.transform('0x4343 xor[0x01]',"").should be == "BB"
        Ciphr.transform('0x01 xor[0x4343]',"").should be == "BB"
        Ciphr.transform('0x00 url', "").should be == '%00'
        Ciphr.transform('"foo" cat', "").should be == 'foo'
    end
  end
end
