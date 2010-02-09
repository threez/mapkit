require "rubygems"
require "sinatra"
require "gd2"
require "maps"
require "sequel"
require "json"

get "/" do
  erb :index
end

DB = Sequel.postgres "varta", :user => "varta", :passwd => "varta"

def points_of_interest(bounding_box)
  top, left, bottom, right = bounding_box.coords
  DB[:points_of_interest].where(:lng => (left..right), :lat => (bottom..top)).
    all.map { |row| Maps::Point.new(row[:lat], row[:lng]) }
end

def points_of_interest_data(bounding_box)
  top, left, bottom, right = bounding_box.coords
  DB[:points_of_interest].where(:lng => (left..right), :lat => (bottom..top)).all
end

ICON_SIZE = 20
EMPTY_IMAGE = File.read("images/empty.png")
GAS_STATION = GD2::Image.import("images/gas.png")

# returns a png for the passed x/y and zoom level
get "/:z/:x/:y.png" do
  x, y, z = params[:x].to_i, params[:y].to_i, params[:z].to_i
  content_type "image/png"
  
  # use default empty image
  image = EMPTY_IMAGE
  
  # find map bounding box
  bounding_box = Maps.bounding_box(x, y, z)
  search_box = bounding_box.grow(10)
  
  # search for points_of_interest
  points = points_of_interest(search_box)
  
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
      # draw icon at position
      x, y = point.pixel(bounding_box)
      x, y = x - 3, y - 20 # position icon at peak point
      
      # copy gas image
      canvas.copy_from(GAS_STATION, x, y, 0, 0, ICON_SIZE, ICON_SIZE)
    end
    
    # dump png
    image = canvas.png
  end

  image
end

# returns points of interest for the passed bounding box
get '/:top/:left/:bottom/:right/:zoom.json' do
  # create search bounding box
  top, left = params[:top].to_f, params[:left].to_f
  bottom, right = params[:bottom].to_f, params[:right].to_f
  zoom = params[:zoom].to_i
  bounding_box = Maps::BoundingBox.new(top, left, bottom, right)
  poi_data = points_of_interest_data(bounding_box)
  
  # create json response
  content_type "text/json"
  {
    "bounding_box" => [top, left, bottom, right],
    "results" => poi_data.map do |point_of_interest|
      north, west = point_of_interest[:lat], point_of_interest[:lng]
      north, west = Maps.shift_latlng(north, west, -3, -20, zoom)
      south, east = Maps.shift_latlng(north, west, 20, 17, zoom)
      
      [
        north, west, south, east,
        point_of_interest[:title], point_of_interest[:address],
        point_of_interest[:city],
        point_of_interest[:lat], point_of_interest[:lng]
      ]
    end
  }.to_json
end
