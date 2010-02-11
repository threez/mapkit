require File.dirname(__FILE__) + "/mapkit"
require "gd2"

module TileKit
  class Icon
    attr_reader :image, :size
    
    def initialize(path, size, peak_position, clickable_area)
      @image = GD2::Image.import(path)
      @size_x, @size_y = size
      @peak_x, @peak_y = peak_position
      @shift_x, @shift_y, @width, @height = clickable_area
    end
    
    def draw(canvas, x, y)
      # position icon at peak point
      x, y = x - @peak_x, y - @peak_y
      
      # copy image
      canvas.copy_from(@image, x, y, 0, 0, @size_x, @size_y)
    end
    
    def bounding_box(lat, lng, zoom)
      top, left = MapKit.shift_latlng(lat, lng, @shift_x - @peak_x, @shift_y - @peak_y, zoom)
      bottom, right = MapKit.shift_latlng(top, left, @width, @height, zoom)
      MapKit::BoundingBox.new(top, left, bottom, right, zoom)
    end
  end
  
  class Image
    attr_reader :canvas, :bounding_box
    
    def initialize(bounding_box)
      @bounding_box = bounding_box
      
      # create image canvas
      @canvas = GD2::Image.new(MapKit::TILE_SIZE, MapKit::TILE_SIZE)

      # make image transparent
      @canvas.save_alpha = true
      @canvas.draw do |context|
        context.color = GD2::Color::TRANSPARENT
        context.fill
      end
    end
    
    # draw icon at position
    def draw_icon(point, icon)
      x, y = point.pixel(@bounding_box)
      icon.draw(@canvas, x, y)
    end
    
    def png
      @canvas.png
    end
  end
end