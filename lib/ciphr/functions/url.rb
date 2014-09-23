require 'cgi'

module Ciphr::Functions::URL
  #TODO: differentiate between URL and CGI encoding (with '+' char)
  class UrlEncoding < Ciphr::Functions::InvertibleFunction
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
end
