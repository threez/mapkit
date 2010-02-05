module Maps
  RADIANT = Math::PI / 180.0
  HALF_PI = Math::PI / 2.0
  TILE_SIZE = 256
  INITIAL_RESOLUTION = 2 * Math::PI * 6378137 / TILE_SIZE
  ORIGIN_SHIFT = 2 * Math::PI * 6378137 / 2.0
  
  # return array of lat/lng for google tiles
  def self.tile(gx, gy, zoom)
    tx, ty = google_tile(gx, gy, zoom)
    tile_latlng_bounds(tx, ty, zoom)
  end
  
  # converts TMS tile coordinates to Google Tile coordinates
  def self.google_tile(tx, ty, zoom)
    # coordinate origin is moved from bottom-left to top-left corner of the extent
    [tx, (2 ** zoom - 1) - ty]
  end
  
  # returns bounds of the given tile in latutude/longitude using WGS84 datum
  def self.tile_latlng_bounds(tx, ty, zoom)
    bounds = tile_bounds(tx, ty, zoom)
    minLat, minLon = meters2latlng(bounds[0], bounds[1])
    maxLat, maxLon = meters2latlng(bounds[2], bounds[3])
     
    [minLat, minLon, maxLat, maxLon]
  end

  # returns bounds of the given tile in EPSG:900913 coordinates
  def self.tile_bounds(tx, ty, zoom)
    minx, miny = pixels2meters(tx * TILE_SIZE, ty * TILE_SIZE, zoom)
    maxx, maxy = pixels2meters((tx + 1) * TILE_SIZE, (ty + 1) * TILE_SIZE, zoom)
    [minx, miny, maxx, maxy]
  end
  
  # converts XY point from Spherical Mercator EPSG:900913 to lat/lon in WGS84 Datum
  def self.meters2latlng(mx, my)
    lon = (mx / ORIGIN_SHIFT) * 180.0
    lat = (my / ORIGIN_SHIFT) * 180.0

    lat = 180 / Math::PI * (2 * Math.atan( Math.exp( lat * RADIANT)) - HALF_PI)
    [lat, lon]
  end

  # converts pixel coordinates in given zoom level of pyramid to EPSG:900913
  def self.pixels2meters(px, py, zoom)
    res = resolution( zoom )
    mx = px * res - ORIGIN_SHIFT
    my = py * res - ORIGIN_SHIFT
    [mx, my]
  end
  
  # Resolution (meters/pixel) for given zoom level (measured at Equator)
  def self.resolution(zoom)
    INITIAL_RESOLUTION / (2 ** zoom)
  end
end
