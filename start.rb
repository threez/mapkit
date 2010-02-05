require "rubygems"
require "sinatra"
require "png"
require "maps"
require "google"

get "/" do
  erb :index
end

# draws star on canvas with passed color and position
def star(canvas, x, y, color, size = 5)
  x, y = x.to_i, y.to_i
  canvas.line(x-size, y, x+size, y, PNG::Color::Red)
  canvas.line(x, y-size, x, y+size, PNG::Color::Red)
end

# returns true if point is in coords
def in?(point, coords)
  top, left, bottom, right = coords
  (left..right) === point[0] && (top..bottom) === point[1]
end

# returns relative x and y for point in coords
def point2pixel(point, coords)
  top, left, bottom, right = coords
  [
    (point[0] - left) / ((right - left) / Maps::TILE_SIZE),
    (point[1] - top) / ((bottom - top) / Maps::TILE_SIZE)
  ]
end

# returns array with width and height of sspn
def coords2sspn(coords)
  top, left, bottom, right = coords
  [right - left, bottom - top]
end

# returns lat/lnt of coords
def center(coords)
  top, left, bottom, right = coords  
  [left + (right - left) / 2, top + (bottom - top) / 2]
end

empty_png = File.read("empty.png")

TERM = "Tankstelle"

get "/:z/:x/:y.png" do
  content_type "image/png"
  # use default empty image
  image = empty_png
  
  # find map coords
  coords = Maps.tile(params[:x].to_i, params[:y].to_i, params[:z].to_i)
  
  for point in Google.search_position(TERM, center(coords), coords2sspn(coords)) do
    # is point in requested tile?
    if in?(point, coords)
      # create image canvas
      canvas = PNG::Canvas.new(Maps::TILE_SIZE, Maps::TILE_SIZE)
    
      # draw star at position
      x, y = point2pixel(point, coords)
      p "star@#{point.inspect} for #{coords.inspect} IMG: #{x}, #{y}"
      star(canvas, x, y, PNG::Color::Red)
    
      # dump png
      image = PNG.new(canvas).to_blob
    end
  end
  
  image
end