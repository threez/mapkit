require 'rubygems'
require 'httparty'

class Google
  include HTTParty
  base_uri "www.google.com"
  default_params :hl => :de, :v => "1.0"
  format :json
  
  def self.search(term, point, sspn)
    resp = get("/uds/GlocalSearch", :query => { :q => term, 
    :sll => point.reverse.join(",") })
    if resp["responseStatus"] == 200
      resp["responseData"]["results"]
    else
      raise Exception.new("Error in Google request")
    end
  end
  
  def self.search_position(term, point, sspn)
    search(term, point, sspn).map { |i| [i["lng"].to_f, i["lat"].to_f] }
  end
end