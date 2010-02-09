require "rubygems"
require "google"
require "sequel"

puts "connect to database..."
DB = Sequel.postgres "varta", :user => "varta", :passwd => "varta"
puts "start crawling..."
Google.crawl_region_to_db(DB[:points_of_interest], "Tankstelle", [48.87, 8.57], 0.005, 4)
puts "crawling finished"