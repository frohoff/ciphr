require 'spec_helper'
require 'ciphr'

describe Ciphr::Stream do
  describe :read do
    it "returns nil after proc does" do
      s = Ciphr::Stream.new Proc.new { nil }
      s.read(1).should be == nil
    end

    it "buffers and returns data as requested" do
      fills = ["abc", "def", "ghi"]
      s = Ciphr::Stream.new Proc.new { fills.shift }
      s.read(1).should be == "a"
      s.read(3).should be == "bcd"
      s.read(1).should be == "e"
      s.read(2).should be == "fg"
      s.read(4).should be == "hi"
      s.read(1).should be == nil
    end

    it "can prepend data and read it back out" do
      fills = ["abc", "def", "ghi"]
      s = Ciphr::Stream.new Proc.new { fills.shift }
      s.read(1).should be == "a"
      s.read(3).should be == "bcd"
      s.prepend("cd")
      s.read(1).should be == "c"
      s.read(1).should be == "d"
      s.read(1).should be == "e"
      s.prepend("cde")
      s.read(3).should be == "cde"
      s.read(2).should be == "fg"
      s.read(4).should be == "hi"
      s.read(1).should be == nil
    end
  end
end
