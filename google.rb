require 'rubygems'
require 'httparty'
require 'maps'

class Google
  include HTTParty
  base_uri "www.google.com"
  default_params :hl => :de, :v => "1.0", :rsz => :large, :filter => 1
  format :json
  
  def self.search(term, point, sspn)
    resp = get("/uds/GlocalSearch", :query => { :q => term, 
    :sll => point.reverse.join(","), :sspn => sspn.join(",") })
    if resp["responseStatus"] == 200
      resp["responseData"]["results"]
    else
      raise Exception.new("Error in Google request")
    end
  end
  
  def self.search_in_bounding_box(term, bounding_box)
    search(term, bounding_box.center, bounding_box.sspn).map do |i| 
      Maps::Point.new(i["lng"].to_f, i["lat"].to_f)
    end
  end
  
  def self.crawl(term, point, sspn)
    array = []
    4.times do |i|
      data = get("/uds/GlocalSearch", :query => { :q => term, :start => i * 8,
      :sll => point.reverse.join(","), :sspn => sspn.join(",") }).to_hash
      array << data["responseData"]["results"]
    end
    array.flatten
  end
end