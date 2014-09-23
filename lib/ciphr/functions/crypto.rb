module Ciphr::Functions::Crypto
  class RC4Cipher < Ciphr::Functions::InvertibleFunction
    def apply
      input, key = @args
      keybytes = key.read.unpack('c*')
      s = (0..255).to_a
      j = 0
      (0..255).each do |i|
        j = (j + s[i] + keybytes[i % keybytes.size]) % 256
        swp = s[i]
        s[i] = s[j]
        s[j] = swp
      end
      i = 0
      j = 0

      $stderr.puts("key: #{keybytes.inspect}")  

      Proc.new do
        byte = input.read(1)
        if byte
          i = (i + 1) % 256
          j = (j + s[i]) % 256
          swp = s[i]
          s[i] = s[j]
          s[j] = swp
          k = s[(s[i] + s[j]) % 256]
          m = [(byte.unpack('c*')[0] ^ k)].pack('c*') 
          m
        else
          nil
        end
      end
    end

    def self.variants
      [[['rc4-ruby'],{}]]
    end

    def self.params 
      [:input, :key]
    end
  end
end
