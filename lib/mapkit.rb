# Module to create tile for the google maps tile overlay
module MapKit
  # consant for radiants
  RADIANT = Math::PI / 180.0
  
  # the size of tiles in google maps
  TILE_SIZE = 256
  
  # the constant earth radius in meters
  EARTH_RADIUS = 6_378_137
  
  # the min latitude based on the mercator projection
  MIN_LATITUDE = -85.05112877
  
  # the max latitude based on the mercator projection
  MAX_LATITUDE = 85.05112877
  
  # the min longitude based on the mercator projection
  MIN_LONGITUDE = -180
  
  # the max longitude based on the mercator projection
  MAX_LONGITUDE = 180
  
  # the resolution in meters per pixel
  RESOLUTION = 2 * Math::PI * EARTH_RADIUS / TILE_SIZE
  
  # version of MapKit
  VERSION = "0.0.2"
  
  # The class represents an lat/lng point
  class Point
    attr_accessor :lat, :lng
  
    # initializes a point object using latitude and longitude
    def initialize(lat, lng)
      @lat, @lng = lat, lng
    end
    
    # returns true if point is in bounding_box, false otherwise
    def in?(bounding_box)
      top, left, bottom, right = bounding_box.coords
      (left..right) === @lng && (top..bottom) === @lat
    end
    
    # returns relative x and y for point in bounding_box
    def pixel(bounding_box)
      top, left, bottom, right = bounding_box.coords
      ws = (right - left) / TILE_SIZE
      hs = (bottom - top) / TILE_SIZE
      [((@lng - left) / ws).to_i, ((@lat - top) / hs).to_i]
    end
  end
  
  # The class represents a bounding box specified by a top/left point and a 
  # bottom/right point (the coordinates can be pixels or degrees)
  class BoundingBox
    attr_accessor :top, :left, :bottom, :right, :zoom
    
    # initialize the bounding box using the positions of two points and a 
    # optional zoom level
    #
    #             top
    #        left o------+
    #             |      |
    #             |      |
    #             +------o right
    #                    bottom
    #
    def initialize(top, left, bottom, right, zoom = nil)
      @top, @left, @bottom, @right, @zoom = top, left, bottom, right, zoom
    end
    
    # returns array of [top, left, bottom, right]
    def coords
      [@top, @left, @bottom, @right]
    end

    # returns array of [width, height] of sspn
    def sspn
      [(@right - @left) / 2, (@bottom - @top) / 2]
    end

    # returns [lat, lnt] of bounding box
    def center
      [@left + (@right - @left) / 2, @top + (@bottom - @top) / 2]
    end
    
    # grow bounding box by percentage
    def grow!(percent)
      lng = percent * ((@right - @left) / 100)
      lat = percent * ((@top - @bottom) / 100)
      @top += lat
      @left -= lng
      @bottom -= lat
      @right += lng
    end
    
    # grow bounding box by percentage and return new bounding box object
    def grow(percent)
      copy = self.clone
      copy.grow!(percent)
      copy
    end
  end
  
  # return bounding box for passed tile coordinates tiles
  def self.bounding_box(tile_x, tile_y, zoom)
    top, left, bottom, right = tile_bounds(tile_x, tile_y, zoom)
    BoundingBox.new(top, left, bottom, right, zoom)
  end

  # returns bounds [top, left, bottom, right] of the given tile 
  # in WGS-94 coordinates
  def self.tile_bounds(tile_x, tile_y, zoom)
    pixel_x, pixel_y = tile2pixel(tile_x, tile_y)
    top, left = pixel2latlng(pixel_x, pixel_y, zoom)
    
    pixel_x, pixel_y = tile2pixel(tile_x + 1, tile_y + 1)
    bottom, right = pixel2latlng(pixel_x, pixel_y, zoom)
    
    [top, left, bottom, right]
  end
  
  # returns [lat, lng] shifted using the passed pixels and zoom
  def self.shift_latlng(lat, lng, shift_x, shift_y, zoom)
    pixel_x, pixel_y = latlng2pixel(lat.to_f, lng.to_f, zoom)
    pixel_x, pixel_y = pixel_x + shift_x, pixel_y + shift_y
    pixel2latlng(pixel_x, pixel_y, zoom)
  end

  # returns pixel coordinates [x, y] based on the passed lat/lng WGS-84
  # coordinates using the specified zoom level
  def self.latlng2pixel(lat, lng, zoom)
    lat = clip(lat.to_f, MIN_LATITUDE, MAX_LATITUDE)
    lng = clip(lng.to_f, MIN_LONGITUDE, MAX_LONGITUDE)
    
    x = (lng + 180.0) / 360.0
    sin_lat = Math.sin(lat * RADIANT)
    y = 0.5 - Math.log((1.0 + sin_lat) / (1.0 - sin_lat)) / (4.0 * Math::PI)
    sx, sy = map_size(zoom)
    
    pixel_x = clip(x * sx + 0.5, 0.0, sx - 1.0)
    pixel_y = clip(y * sy + 0.5, 0.0, sy - 1.0)
    [pixel_x.to_i, pixel_y.to_i]
  end
  
  # returns lat/lng WGS-84 coordinates [lat, lng] basedon the passed pixel
  # coordinates using the specified zoom level
  def self.pixel2latlng(pixel_x, pixel_y, zoom)
    sx, sy = map_size(zoom)
    x = clip(pixel_x.to_f, 0.0, sx - 1.0) / sx - 0.5
    y = 0.5 - clip(pixel_y.to_f, 0.0, sy - 1.0) / sy
    
    lat = 90.0 - 360.0 * Math.atan(Math.exp(-y * 2.0 * Math::PI)) / Math::PI
    lng = 360.0 * x
    [lat, lng]
  end

  # returns the passed value in case it is in the passed range or the 
  # bounding min or max value 
  def self.clip(val, min, max)
    (val < min) ? min : (val > max) ? max : val
  end

  # returns coordinates of tiles using passed pixel coordinates
  def self.pixel2tile(pixel_x, pixel_y)
    [pixel_x / TILE_SIZE, pixel_y / TILE_SIZE]
  end
  
  # returns coordinates of pixels using passed tile coordinates
  def self.tile2pixel(tile_x, tile_y)
    [tile_x * TILE_SIZE, tile_y * TILE_SIZE]
  end
  
  # returns the size [x, y] of the map using the passed zoom level
  def self.map_size(zoom)
    [TILE_SIZE << zoom, TILE_SIZE << zoom]
  end
  
  # returns resolution in meters per pixel for passed zoom level
  def self.resolution(zoom)
    RESOLUTION / (2 ** zoom)
  end
end
