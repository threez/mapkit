require "rubygems"
require "sinatra"
require "gd2"
require "google"
require "sequel"

get "/" do
  erb :index
end

DB = Sequel.postgres "varta", :user => "varta", :passwd => "varta"

def points(bounding_box)
  top, left, bottom, right = bounding_box.coords
  data = DB[:points_of_interest].where(:lng => (left..right), :lat => (top..bottom)).all
  data.map { |row| Maps::Point.new(row[:lng], row[:lat]) }
end

TERM = "Tankstelle"
ICON_SIZE = 20
EMPTY_IMAGE = File.read("images/empty.png")
GAS_STATION = GD2::Image.import("images/gas.png")

get "/:z/:x/:y.png" do
  content_type "image/png"
  # use default empty image
  image = EMPTY_IMAGE
  
  # find map bounding box
  bounding_box = Maps.bounding_box(params[:x].to_i, params[:y].to_i, params[:z].to_i)
  search_box = bounding_box.grow(20)
  
  #points = Google.search_in_bounding_box(TERM, search_box)
  points = points(search_box)
  
  unless points.empty?
    # create image canvas
    canvas = GD2::Image.new(Maps::TILE_SIZE, Maps::TILE_SIZE)
                           
    # make image transparent
    canvas.save_alpha = true
    canvas.draw do |context|
      context.color = GD2::Color::TRANSPARENT
      context.fill
    end
    
    for point in points do
      # draw star at position
      x, y = point.pixel(bounding_box)
      x, y = x - 3, y - 20 # position icon image to peak point
      
      # copy gas image
      canvas.copy_from(GAS_STATION, x, y, 0, 0, ICON_SIZE, ICON_SIZE)
    end
    
    # dump png
    image = canvas.png
  end

  image
end
