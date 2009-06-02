require "rubygems"
require "pathname"
require 'nokogiri'
require "restclient"

$LOAD_PATH.unshift(File.expand_path("../", __FILE__))

# Allows for pathnames to be easily added to
class Pathname
  def /(other)
    join(other.to_s)
  end
end

# A Ruby interface to the VTWhite Provisioning Web API
module Vtwhite4r
  autoload :VERSION, "vtwhite4r/version"
  autoload :Error, "vtwhite4r/error"
  ROOT = Pathname($LOAD_PATH.first) unless Vtwhite4r.const_defined?("ROOT")
  LIBDIR = ROOT/:lib unless Vtwhite4r.const_defined?("LIBDIR")

  # This class represents the VT White interface, with the methods
  # of their XML interface mapped to methods of API instances
  class API
    attr_reader :uri, :pass, :username

    # @param [String, #to_s] pass
    # your VT White provided API pass
    # @param [String, #to_s] username
    # your VT White provided API username
    # @param [String, #to_s] uri
    # your VT White provided API uri (if different from the default)
    def initialize(pass, username, uri = nil) # {{{
      @pass = pass.to_s
      @username = username.to_s
      # The base uri requests will be sent to VT White with
      @uri = uri
      #@uri ||= "https://api.vtwhite.com/provisioning/testprovisioning.api.php" # Development/Testing
      @uri ||= "https://api.vtwhite.com/provisioning/provisioning.api.php" # Production
    end # }}}

    # List numbers for a certain NPA
    # @param [String, #to_s] npa
    # The NPA to search for (first 3 of NPANXX######)
    # @return [Hash] the :tier1 => [] and :tier2 => [] numbers available for that NPA
    def list_numbers(npa)
      get_numbers(:npa => npa)
    end

    # List numbers for given criteria
    # @param [Hash] args
    # The hash containing search criteria (npa, nxx, or state)
    # @return [Hash] the :tier1 => [] and :tier2 => [] numbers available for that NPA
    def get_numbers(args = {})
      doc = request("GetNumbers", args)
      unless error_state(doc)
        raw_list = %w[city fax npa nxx state tier].map{|tag| doc.css(tag).map{|i| i.inner_text } }.transpose
        list = raw_list.map { |num| {:city => num[0], :fax => num[1], :npa => num[2], :nxx => num[3], :state => num[4], :tier => num[5] } }
      else
        raise Vtwhite4r::Error, error_state(doc)
      end
    end

    # Add a telephone number to the account
    # @param [Hash] args
    # The hash containing assignment criteria (npa, nxx)
    # @return [String, #to_s] the assigned number
    def add_number(args = {})
      doc = request("AddNumber", args)
      unless error_state(doc)
        number = doc.xpath("//packet/data/return").inner_html
      else
        raise Vtwhite4r::Error, error_state(doc)
      end
    end

    # Remove a telephone number from the account
    # @param [String, #to_s] number
    # The telephone number to remove
    # @return [String, #to_s] the assigned number
    def remove_number(number)
      num = number.to_s
      doc = request("RemoveNumber", :number => num)
      result = error_state(doc)
      if result
        raise(Vtwhite4r::Error, "Removing #{num} failed. Response was: #{result}")
      else
        true
      end
    end

    private

    def successful_request?(res)
      res.xpath("//packet/data/success").inner_html == "TRUE" ? true : false
    end

    def error_state(res)
      return false if successful_request?(res)
      res.xpath("//packet/data/error").inner_html
    end

    def request_uri(service, args = {})
      default = { :method => service, :pass => pass, :username => username }
      query_hash = default.merge(args)
      URI + query_hash.map{|k,v| "#{escape(k)}=#{escape(v)}" }.join('&')
    end

    def request(service, args = {})
      Nokogiri::HTML(RestClient.post(@uri, 'packet' => request_template(service,args)))
    end

    def request_template(service, args = {}) # {{{ Should this break out into a template and a builder?
      xml = <<XML
<packet>
  <auth>
    <user>#{@username}</user>
    <pass>#{@pass}</pass>
  </auth>
  <function>#{service}</function>
XML
      unless args == {}
        xml += "  <data>\n"
        xml +=  args.map{|k,v| "    <#{escape(k.to_s)}>#{escape(v.to_s)}</#{escape(k.to_s)}>"}.join("\n")
        xml += "\n  </data>\n"
      end
      xml += "</packet>"
    end # }}}

    # Performs URI escaping so that you can construct proper
    # query strings faster.
    # Use this rather than the cgi.rb version since it's
    # faster.
    # (Stolen from Rack which stole it from Camping).
    def escape(s)
      s.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/n) {
        '%'+$1.unpack('H2'*$1.size).join('%').upcase
      }.tr(' ', '+')
    end
  end
end
