require File.dirname(__FILE__) + "/mapkit"
require 'RMagick' unless defined? Magick

# this module helps drawing icons on tile images
module TileKit
  # this class represents an icon that can be drawn on an Image
  class Icon
    attr_reader :image, :size

    # initializes the icon with a path, image size [width, height], the peak#
    # position (where the pointer should be placed) [x, y] and a bounding box
    # that represents a clickable area
    # path:: the path of the image (test.png)
    # size:: the size of the immage as array [width, height]
    # peak_position:: the peak position as array [x, y]
    # clickable_area:: the clickable area of the icon as array [top, left, bottom, right]
    def initialize(path, size, peak_position, clickable_area)
      @image = Magick::Image.read(path)[0]
      @size_x, @size_y = size
      @peak_x, @peak_y = peak_position
      @shift_x, @shift_y, @width, @height = clickable_area
    end

    # draws the icon on the canvas at passed position (x, y)
    def draw(canvas, x, y)
      # position icon at peak point
      x, y = x - @peak_x, y - @peak_y

      # copy image
      canvas.composite!(@image, Magick::ForgetGravity, x, y, Magick::CopyCompositeOp)
    end

    # returns a boundingbox (with lat/lng) that contains the bounds of the
    # image for the passed position
    def bounding_box(lat, lng, zoom)
      top, left = MapKit.shift_latlng(lat, lng, @shift_x - @peak_x, @shift_y - @peak_y, zoom)
      bottom, right = MapKit.shift_latlng(top, left, @width, @height, zoom)
      MapKit::BoundingBox.new(top, left, bottom, right, zoom)
    end
  end

  # this image class represents a tile in the google maps
  class Image
    attr_reader :canvas, :bounding_box

    # initialize the image with a (lat/lng) bounding box of the tile it
    # represents
    def initialize(bounding_box)
      @bounding_box = bounding_box

      # create transparent image canvas
      @canvas = Magick::Image.new(MapKit::TILE_SIZE, MapKit::TILE_SIZE) do |c|
        c.background_color= "Transparent"
      end
    end

    # draws passed icon at passed position
    def draw_icon(point, icon)
      x, y = point.pixel(@bounding_box)
      icon.draw(@canvas, x, y)
    end

    # returns the png binary string of the image
    def png
      @canvas.to_blob { |attrs| attrs.format = 'PNG' }
    end
  end
end
