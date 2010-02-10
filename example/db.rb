#!/usr/bin/ruby
require "rubygems"
require "google_local"
require "sequel"

class PointsOfInterest
  def initialize
    db = File.dirname(__FILE__) + "/db.sqlite3"
    init = File.dirname(__FILE__) + "/database.sql"
    `sqlite3 #{db} < #{init}` unless File.exists? db
    @db = Sequel.sqlite(db)
    @table = @db[:points_of_interest]
  end
  
  # returns the points as array (MapKit::Point) that are in the bounding_box
  def points(bounding_box)
    top, left, bottom, right = bounding_box.coords
    @table.where(:lng => (left..right), :lat => (bottom..top)).all.
      map { |row| MapKit::Point.new(row[:lat], row[:lng]) }
  end
  
  # returns the database rows that are in the bounding_box
  def data(bounding_box)
    top, left, bottom, right = bounding_box.coords
    @table.where(:lng => (left..right), :lat => (bottom..top)).all
  end
  
  # searches for term beginning at point with a spanning of span n times n
  def self.crawl_region_to_db(term, point, span, n = 10)
    GoogleLocal.crawl_region(term, point, span, n) do |row|
      address, city = row["addressLines"]
      @table.insert(:lat => row['lat'].to_f, :lng => row['lng'].to_f,
                     :title => row['title'], :address => address, :city => city)
    end
    
    DB.run "update points_of_interest set flag = 1 where id in " \
           "(select min(id) FROM points_of_interest group by lat, lng)"
    DB.run "delete from points_of_interest where flag is null"
  end
end

POI = PointsOfInterest.new

if __FILE__ == $0
  puts "start crawling..."
  POI.crawl_region_to_db(DB[:points_of_interest], "Tankstelle", [48.87, 8.57], 0.005, 4)
  puts "crawling finished"  
end

