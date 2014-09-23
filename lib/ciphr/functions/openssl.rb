require 'openssl'

module Ciphr::Functions::OpenSSL
  OPENSSL_DIGESTS = %w(md4 md5 sha sha1 sha224 sha256 sha384 sha512) # no md2
  #TODO: fail/ignore gracefully with error/warning if openssl unavailable

  class OpenSslDigest < Ciphr::Functions::Function
    def self.variants
      OPENSSL_DIGESTS.map{|d| [d, {:variant => d}]}
    end

    def self.params
      [:input]
    end

    def apply
      input = args[0]
      digester = OpenSSL::Digest.new(@options[:variant])
      while chunk = input.read(256)
        digester.update(chunk)
      end
      digest = digester.digest
      Proc.new do
        d = digest
        digest = nil
        d
      end
    end
  end

  class OpenSslHmac < OpenSslDigest
    def self.variants
      OPENSSL_DIGESTS.map{|d| [["hmac-#{d}", "hmac#{d}"], {:variant => d}]}        
    end

    def self.params 
      [:input, :key]
    end

    # reuse code from Digest.apply
    def apply
      input, key = @args
      digester = OpenSSL::HMAC.new(key.read, @options[:variant])
      while chunk = input.read(256)
        digester.update(chunk)
      end
      digest = digester.digest
      Proc.new do
        d = digest
        digest = nil
        d
      end
    end
  end



  class OpenSslCipher < Ciphr::Functions::InvertibleFunction
    def apply
      input, key = @args
      cipher = OpenSSL::Cipher.new(@options[:variant])
      cipher.send(invert ? :decrypt : :encrypt)
      cipher.key = key.read
      random_iv = cipher.random_iv
      if random_iv.size > 0
        cipher.iv = invert ? input.read(random_iv.size) : random_iv
      end
      Proc.new do
        if ! invert && random_iv
          begin
            random_iv
          ensure
            random_iv = nil
          end
        else
          chunk = input.read(256)
          if cipher
            if chunk
              cipher.update(chunk)
            else
              begin
                cipher.final
              ensure
                cipher = nil
              end
            end
          else
            nil
          end
        end
      end
    end

    def self.variants
      OpenSSL::Cipher.ciphers.map{|c| c.downcase}.uniq.map do |c|
        [[c, c.gsub(/-/, "")], {:variant => c}]
      end
    end

    def self.params 
      [:input, :key]
    end
  end
end
