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
    crawl(term, bounding_box.center, bounding_box.sspn).map do |i| 
      Maps::Point.new(i["lng"].to_f, i["lat"].to_f)
    end
  end
  
  def self.crawl(term, point, sspn)
    array = []
    4.times do |i|
      data = get("/uds/GlocalSearch", :query => { :q => term, :start => i * 8,
      :sll => point.reverse.join(","), :sspn => sspn.join(",") }).to_hash
      if data["responseStatus"] == 200
        data["responseData"]["results"].each do |row|
          array << ([row['lat'], row['lng'], row['title']] + row["addressLines"])
        end
      else
        raise Exception.new("Error in Google request")
      end
    end
    array
  end
  
  def self.crawl_region(term, point, span, n = 10)
    array = []
    half_span = span / 2
    n.times do |x|
      n.times do |y|
        point = [point[0] + x * half_span, point[1] + y * half_span]
        array += crawl(term, point, [half_span, half_span])
        print "."
      end
    end
    array
  end
  
  def self.crawl_region_to_file(filename, term, point, span, n = 10)
    data = Google.crawl_region(term, point, span, n)
    File.open("test.data", "w") do |f| 
      f.write(data.map { |r| r.join("|") }.join("\n"))
    end
  end
end