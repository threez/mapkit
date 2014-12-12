require "sinatra"
require "./db"
require "tilekit"
require "json"

EMPTY_IMAGE = File.read("images/empty.png")
GAS_STATION = TileKit::Icon.new("images/gas.png", [20, 20],
                                [3, 20], [0, 0, 20, 17])

get "/" do
  erb :index
end

# returns a png for the passed x/y and zoom level
get "/:z/:x/:y.png" do
  x, y, z = params[:x].to_i, params[:y].to_i, params[:z].to_i
  content_type "image/png"

  # use default empty image
  image = EMPTY_IMAGE

  # find map bounding box
  bounding_box = MapKit.bounding_box(x, y, z)

  # search for points_of_interest in a bigger bouning box (grow by 10%)
  points = POI.points(bounding_box.grow(10))

  unless points.empty?
    tile = TileKit::Image.new(bounding_box)

    for point in points do
      tile.draw_icon(point, GAS_STATION)
    end

    image = tile.png
  end

  image
end

# returns points of interest for the passed bounding box as json
get '/:top/:left/:bottom/:right/:zoom.json' do
  # create search bounding box
  top, left = params[:top].to_f, params[:left].to_f
  bottom, right = params[:bottom].to_f, params[:right].to_f
  zoom = params[:zoom].to_i

  bounding_box = MapKit::BoundingBox.new(top, left, bottom, right, zoom)
  poi_data = POI.data(bounding_box)

  # create json response
  content_type "text/json"
  {
    "bounding_box" => [top, left, bottom, right],
    "results" => poi_data.map do |poi|
      GAS_STATION.bounding_box(poi[:lat], poi[:lng], zoom).coords + [
        poi[:title], poi[:address], poi[:city], poi[:lat], poi[:lng]
      ]
    end
  }.to_json
end
