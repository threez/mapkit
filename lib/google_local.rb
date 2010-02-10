require File.dirname(__FILE__) + "/mapkit"
require 'httparty'

# Class for searching with the google local search
class GoogleLocal
  include HTTParty
  base_uri "www.google.com"
  default_params :hl => :de, :v => "1.0", :rsz => :large
  format :json
  
  # searches a term near point with sspn (span in degrees)
  def self.search(term, point, sspn)
    resp = get("/uds/GlocalSearch", :query => { :q => term, 
    :sll => point.join(","), :sspn => sspn.join(",") })
    if resp["responseStatus"] == 200
      resp["responseData"]["results"]
    else
      raise Exception.new("Error in Google request")
    end
  end
  
  # just searches a term in a bounding box and returns points
  def self.search_in_bounding_box(term, bounding_box)
    crawl(term, bounding_box.center, bounding_box.sspn).map do |i| 
      MapKit::Point.new(i["lat"].to_f, i["lng"].to_f)
    end
  end
  
  # searches a term near point with sspn (span in degrees)
  def self.crawl(term, point, sspn)
    print " - crawl for '#{term}' at #{point.inspect} within #{sspn.inspect} ("
    count = 0
    4.times do |i|
      data = get("/uds/GlocalSearch", :query => { :q => term, :start => i * 8,
      :sll => point.join(","), :sspn => sspn.join(",") }).to_hash
      if data["responseStatus"] == 200
        data["responseData"]["results"].each do |row|
          yield(row)
          count += 1
        end
      else
        raise Exception.new("Error in Google request")
      end
      print "."
    end  
    print ") results: #{count}\n"
  end
  
  # searches a term near point with sspn (span in degrees) n times n
  def self.crawl_region(term, point, span, n = 10, &block) # :yields: data
    half_span = span / 2
    n.times do |x|
      n.times do |y|
        point = [point[0] + x * half_span, point[1] + y * half_span]
        crawl(term, point, [half_span, half_span], &block)
      end
    end
  end
end