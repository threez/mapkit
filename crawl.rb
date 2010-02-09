require "rubygems"
require "google"
require "sequel"

puts "connect to database..."
DB = Sequel.postgres "varta", :user => "varta", :passwd => "varta"
puts "start crawling..."
Google.crawl_region_to_db(DB[:points_of_interest], "Tankstelle", [48.87, 8.57], 0.005, 4)
puts "crawling finished"
puts "remove duplicates..."
DB.run "update points_of_interest set flag = 1 where id in (select min(id) FROM points_of_interest group by lat, lng)"
DB.run "delete from points_of_interest where flag is null"
puts "removed duplicates"