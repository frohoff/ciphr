require 'openssl'
require 'base64'
require 'cgi'
require 'base32'
require 'zlib'
require 'securerandom'
#require 'base32/crockford'
#require 'zbase32'

module Ciphr
	module Functions

		# http://stackoverflow.com/questions/746207/ruby-design-pattern-how-to-make-an-extensible-factory-class

		@function_classes = []
		@functions = []
		@function_aliases = {}

		def self.register(klass)
			@function_classes << klass
		end

		def self.setup(classes=@function_classes)
			@functions = classes.map{|c| [c,c.variants]}.select{|a| a[1] && a[1].size > 0}.map{|a| 
				[a[0], a[1].map{|v| [[v[0]].flatten.uniq, v[1]]}]}
			@function_aliases = Hash[@functions.map{|c,vs| vs.map{|v| [v[0]].flatten.map{|n| [n,[c, v[1]]]}}.flatten(1)}.flatten(1)]
		end

		def self.function_aliases
			@function_aliases
		end

		def self.[](name)
			@function_aliases[name] || (raise InvalidFunctionError.new(name))
		end

		def self.functions
			@functions
		end

		class Function
			def initialize(options, args)
				@options = options
				@args = args
				@stream = Ciphr::Stream.new(self)
			end
			attr_accessor :options, :args #don't like that these are both writable, but c'est la vie

			def self.variants
				[]
			end

			def self.inherited(subclass)
				Ciphr::Functions.register(subclass)
			end

			def self.params
				[]
			end

			def self.invertable?
				false
			end

			def self.aligned
				nil
			end

			def read(*args)
				@stream.read(*args)
			end

			def prepend(*args)
				@stream.prepend(*args)
			end
		end

		class InvertibleFunction < Function
			@invert = false
			attr_accessor :invert   

			def self.invertable?
				true
			end 
		end

		class Cat < Function
			def self.variants
				[[['cat','catenate'], {}]]
			end

			def self.params
				[:input]
			end

			def apply
				inputs = @args
				i = 0
				chunk = nil
				Proc.new do
					chunk = inputs[i].read(256)
					if ! chunk
						i += 1
						chunk = inputs[i] && inputs[i].read(256)
					end
					#while !(chunk = inputs[i].read(256)) && i < inputs.size
					#  i++
					#end 
					chunk
				end
			end
		end 

		class Base < InvertibleFunction
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

		class Radix < InvertibleFunction
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

		#TODO: differentiate between URL and CGI encoding (with '+' char)
		class UrlEncoding < InvertibleFunction
			def apply
				input = @args[0]
				if !invert
					Proc.new do
						chunk = input.read(1)
						chunk && CGI.escape(chunk)
					end
				else
					Proc.new do
						chunk = input.read(1)
						if (chunk == "%")
							chunk += input.read(2)
							chunk && CGI.unescape(chunk)
						elsif chunk == '+'
							' '
						else
							chunk
						end
					end
				end
			end

			def self.variants
				[
					[['url','uri','cgi'],{}]
				]
			end

			def self.params 
				[:input]
			end      
		end

		class BinaryTruncBitwise < Function
			def apply
				input,keyinput = @args
				Proc.new do
					keychunk = keyinput.read(256)
					inchunk = input.read(256)
					if inchunk && keychunk
						a,b=[inchunk,keychunk].sort_by{|x| x.size}
						a.bytes.each_with_index.map{|c,i|c.send(@options[:op], b.bytes.to_a[i%b.size])}.pack("c*")
					else
						nil
					end
				end
			end

			def self.variants
				[
					['and-trunc', {:op=>:&}],
					['or-trunc', {:op=>:|}],
					[['xor-trunc'], {:op=>:'^'}]
				]
			end

			def self.params
				[:input, :input]
			end
		end

		class BinaryBitwise < Function
			def apply
				input,keyinput = @args
				if !keyinput.nil?
					keyb = keyinput.read.bytes.to_a
				end
				Proc.new do
					if !keyb.nil? && 0 < keyb.size
						inchunk = input.read(keyb.size)
					else
						inchunk = input.read
						keyb = SecureRandom.random_bytes(inchunk.size).bytes.to_a
					end					
						if inchunk
							inchunkb = inchunk.bytes.to_a
							inchunkb.each_with_index.map{|c,i|c.send(@options[:op], keyb[i%inchunkb.size])}.pack("c*")
						else
							nil
						end
				end
			end

			def self.variants
				[
					['and', {:op=>:&}],
					['or', {:op=>:|}],
					[['xor'], {:op=>:'^'}]
				]
			end

			def self.params
				[:input, :input]
			end
		end

		class UnaryBitwise < Function
			def apply
				input = @args[0]
				Proc.new do
					inchunk = input.read(1)
					if inchunk
						inchunk.bytes.map{|b| b = ~b }.pack("c*")
					else
						nil
					end
				end
			end

			def self.variants
				[ ['not', {}] ]
			end

			def self.params
				[:input]
			end
		end

		class Repack < Function
			def apply
				input, ch1in, ch2in = @args
				content, ch1, ch2 = [input.read, ch1in.read, ch2in.read]
				Proc.new do
					if content
						begin
							content.unpack(ch1).pack(ch2)
						ensure
							content = nil
						end
					else
						nil
					end
				end
			end

			def self.variants
				[ [['repack'], {}] ]
			end

			def self.params
				[:input,:ch1,:ch2]
			end
		end

		class Translate < Function
			def apply
				input, ch1in, ch2in = @args
				ch1, ch2 = [ch1in.read, ch2in.read]
				Proc.new do
					inchunk = input.read(1)
					if inchunk
						inchunk.tr(ch1, ch2)
					else
						nil
					end
				end
			end

			def self.variants
				[ [['tr','translate'], {}] ]
			end

			def self.params
				[:input,:ch1,:ch2]
			end
		end

		class Replace < Function
			def apply
				input, searchin, replacein = @args
				search, replace = [searchin.read, replacein.read]
				buf = ""
				Proc.new do
					if buf.size == search.size && search.size > 0
						buf = ""
						replace
					else
						inchunk = input.read(1)
						if inchunk 
							if inchunk == search[buf.size]
								buf += inchunk
								""
							else
								buf += inchunk
								input.prepend(buf[1,buf.size])
								ret = buf[0]
								buf = ""
								ret
							end
						else
							if buf.size > 0
								ret = buf
								buf = ""
								ret
							else
								nil
							end
						end
					end
				end
			end

			def self.variants
				[ [['repl','replace'], {}] ]
			end

			def self.params
				[:input,:search,:replace]
			end
		end

		OPENSSL_DIGESTS = %w(md4 md5 sha sha1 sha224 sha256 sha384 sha512) # no md2

		class OpenSslDigest < Function
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



		class OpenSslCipher < InvertibleFunction
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

		class Deflate < InvertibleFunction
			def apply
				input = @args[0]
				zstream = invert ? Zlib::Inflate.new : Zlib::Deflate.new
				Proc.new do
					chunk = input.read(256)
					if chunk
						if invert
							zstream.inflate(chunk)
						else
							zstream.deflate(chunk,Zlib::SYNC_FLUSH)
						end
					else
						begin
							#zstream.finish if invert
						ensure
							zstream.close
						end
					end
				end
			end

			def self.variants
				[
					[['deflate'], {}]
				]
			end

			def self.params 
				[:input]
			end
		end


		class Gzip < InvertibleFunction
			class UncloseableIOProxy # hack to prevent GzipWriter from closing StringIO
				def initialize(delegate)
					@delegate = delegate
				end

				def method_missing(meth, *args, &block)
					if meth.to_s != "close"
						@delegate.send(meth, *args, &block)
					else
						nil
					end
				end
			end

			def apply
				input = @args[0]
				sio = StringIO.new
				gz = !invert ? Zlib::GzipWriter.new(UncloseableIOProxy.new(sio)) : Zlib::GzipReader.new(input) 
				Proc.new do
					if invert # unzip
						gz.read(256)
					else # zip
						chunk = input.read(256)
						if chunk
							gz.write chunk 
							sio.rewind
							ret = sio.read
							sio.rewind
							sio.truncate(0)
							ret
						elsif gz
							gz.close
							gz = nil
							sio.rewind
							ret = sio.read
							sio.rewind
							sio.truncate(0)
							ret
						else
							nil
						end
					end
				end
			end

			def self.variants
				[
					[['gzip','gz'], {}]
				]
			end

			def self.params 
				[:input]
			end
		end

		class StringReader < Function
			def apply
				StringProc.new(options[:string])
			end

			class StringProc #extend Proc?
				def initialize(str)
					@str = str
				end

				def call
					begin
						@str
					ensure
						@str = nil
					end
				end
			end      
		end

		class FileReader < Function
			def apply
				f = File.open(options[:file], "r")
				Proc.new do
					chunk = f.read(256)
					f.close if ! chunk
					chunk
				end
			end
		end

		class StdInReader < Function
			def apply
				Proc.new do
					$stdin.read(256)
				end
			end
		end

		class IoReader < Function
			def apply
				input = args[0]
				Proc.new do
					input.read(256)
				end
			end
		end    

		class InvalidFunctionError < StandardError
			attr_reader :name
			def initialize(name)
				@name = name
			end
		end


		class RC4Cipher < InvertibleFunction
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
end
