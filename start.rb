require "rubygems"
require "sinatra"
require "png"
require "google"

get "/" do
  erb :index
end

# draws star on canvas with passed color and position
def star(canvas, x, y, color, size = 5)
  x, y = x.to_i, y.to_i
  if (0...Maps::TILE_SIZE) === x-size &&
     (0...Maps::TILE_SIZE) === x+size &&
     (0...Maps::TILE_SIZE) === y-size &&
     (0...Maps::TILE_SIZE) === y+size
    canvas.line(x-size, y, x+size, y, PNG::Color::Red)
    canvas.line(x, y-size, x, y+size, PNG::Color::Red)
  else
    canvas[x, y] = PNG::Color::Red
  end
end

empty_png = File.read("empty.png")

TERM = "Tankstelle"

get "/:z/:x/:y.png" do
  content_type "image/png"
  # use default empty image
  image = empty_png
  
  # find map coords
  bounding_box = Maps.bounding_box(params[:x].to_i, params[:y].to_i, params[:z].to_i)
  
  for point in Google.search_in_bounding_box(TERM, bounding_box) do
    # is point in requested tile?
    if point.in?(bounding_box)
      # create image canvas
      canvas = PNG::Canvas.new(Maps::TILE_SIZE, Maps::TILE_SIZE)
    
      # draw star at position
      x, y = point.pixel(bounding_box)
      star(canvas, x, y, PNG::Color::Red)
    
      # dump png
      image = PNG.new(canvas).to_blob
    end
  end
  
  image
end