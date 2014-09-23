require 'base64'
require 'base32'

module Ciphr::Functions::Base
  class Base < Ciphr::Functions::InvertibleFunction
    def self.aligned
      :left
    end      
  end

  class Base2 < Base
    def self.variants
      [[['b2','base2', 'bin','binary'], {}]]
    end

    def self.params
      [:input]
    end

    def apply
      input = @args[0]
      if !invert              
        Proc.new do
          chunk = input.read(1)
          chunk && chunk.unpack("B*")[0]
        end
      else
        Proc.new do
          chunk = input.read(8)
          chunk && [chunk].pack("B*")
        end
      end
    end
  end

  class Base8 < Base
    def self.variants
      [[['b8','base8','oct','octal'], {}]]
    end

    def self.params
      [:input]
    end

    def apply
      input = @args[0]
      if !invert              
        Proc.new do
          chunk = input.read(3)
          chunk = chunk && chunk + "\x00"*(3-chunk.size) #pad
          chunk && chunk.unpack("B*")[0].bytes.to_a.each_slice(3).to_a.map{|a|a.pack("c*").to_i(2).to_s(8)}.join
        end
      else
        Proc.new do
          chunk = input.read(8)
          chunk = chunk && chunk + "0"*(8-chunk.size) #pad
          chunk && chunk.unpack("aaaaaaaa").map{|o| o.to_i.to_s(2).rjust(3,"0")}.join.unpack("a8a8a8").map{|b| b.to_i(2)}.pack("C*")
        end
      end
    end
  end

  class Base16 < Base
    def self.variants
      [[['b16','base16','hex','hexidecimal'], {}]]
    end

    def self.params
      [:input]
    end

    def apply
      input = @args[0]
      if !invert              
        Proc.new do
          chunk = input.read(1)
          chunk && chunk.unpack("H*")[0]
        end
      else
        Proc.new do
          chunk = input.read(2)
          chunk && [chunk].pack("H*")
        end
      end
    end
  end


  class Base32 < Base
    def self.variants
      [
        [['b32','base32','b32-std','base32-std'], {:object => ::Base32 }]#, 
        #broken
        #[['b32-crockford','base32-crockford'], {:object => ::Base32::Crockford }],
        #[['b32-z','base32-z'], {:object => ZBase32.new }]
      ]
    end

    def self.params
      [:input]
    end

    def apply
      input = @args[0]
      if !invert              
        Proc.new do
          chunk = input.read(5)
          chunk && options[:object].encode(chunk)
        end
      else
        Proc.new do
          chunk = input.read(8)
          chunk && options[:object].decode(chunk)
        end
      end
    end
  end

  class Base64 < Base
    def self.aligned
      nil # preserves alignment
    end      
    
    def apply    
      input = @args[0]
      if !invert
        Proc.new do
          chunk = input.read(3)
          chunk && ::Base64.encode64(chunk).gsub(/\s/,'').tr("+/", options[:chars][0,2]).tr("=", options[:chars][2,3])
        end
      else
        Proc.new do
          chunk = input.read(4)
          chunk = chunk && chunk + "="*(4-chunk.size) #pad
          chunk && ::Base64.decode64(chunk.tr(options[:chars][0,2],"+/").tr(options[:chars][2,3],"=").ljust(4,"="))
        end
      end
    end

    def self.variants
      chars = {"+"=>"p", "-"=>"h", "_"=>"u", ":"=>"c", "/"=>"s", "." => "d", "!"=>"x", "="=>"q"}
      types = {"+/=" => ["std"], "+/" => "utf7", "+-" => "file", "-_" => "url", "._-" => "yui", 
               ".-" => "xml-name", "_:" => "xml-id", "_-" => "prog-id-1", "._" => "prog-id-2", "!-" => "regex"}
      variants = types.map{|c,n| [["b64","base64"].product([c.chars.map{|c| chars[c] }.join,n]).map{|a| a.join("-")}, {:chars => c}]}
      std = variants.select{|v| v[0].include? "b64-std"}[0] #add short aliases for standard
      std[0] = ["b64","base64"].concat(std[0])
      variants
    end

    def self.params 
      [:input]
    end
  end    

end

module Ciphr::Functions::Radix


  class Radix < Ciphr::Functions::InvertibleFunction
    def self.aligned
      :right
    end
    
    def self.variants
      (2..36).map{|r| [["r#{r}","rad#{r}","radix#{r}"], {:radix => r}]}
    end

    def self.params
      [:input]
    end

    def apply
      radix = options[:radix]
      input = @args[0]
      if !invert     
        num = 0      
        while chunk = input.read(1)
          num = (num << 8) + chunk.bytes.to_a[0]
        end
        Proc.new do
          begin
            num && num.to_s(radix)
          ensure
            num = nil
          end
        end
      else
        num = input.read().to_i(radix)
        bytes = []
        while num > 0
          bytes.unshift(num & 0xff)
          num = num >> 8
        end
        Proc.new do
          begin
            bytes && bytes.pack("c*")
          ensure
            bytes = nil
          end
        end
      end
    end
  end  
end
