require File.dirname(__FILE__) + '/spec_helper'

describe Maps::Point do
  it "should save and restore lat/lng" do
    point = Maps::Point.new(45, 45)
    point.lat.should == 45
    point.lng.should == 45
    point.lat = 10
    point.lng = 15
    point.lat.should == 10
    point.lng.should == 15
  end
  
  it "should be able to check if it is in a bounding box" do
    point0 = Maps::Point.new(45, 45)
    point1 = Maps::Point.new(60, 45)
    point2 = Maps::Point.new(60, 60)
    box = Maps::BoundingBox.new(40, 40, 50, 50)
    point0.in?(box).should == true
    point1.in?(box).should == false
    point2.in?(box).should == false
  end
  
  it "should be able to calc relative positions based on the bounding box" do
    point = Maps::Point.new(45, 45)
    box = Maps::BoundingBox.new(40.0, 40.0, 50.0, 50.0)
    point.pixel(box).should == [Maps::TILE_SIZE / 2, Maps::TILE_SIZE / 2]
  end
end

describe Maps::BoundingBox do
  it "should initialize correctly" do
    box = Maps::BoundingBox.new(1, 2, 3, 4)
    box.coords.should == [1, 2, 3, 4]
    box.top.should == 1
    box.left.should == 2
    box.bottom.should == 3
    box.right.should == 4
  end
  
  it "should calculate the span" do
    box = Maps::BoundingBox.new(0, 0, 3.0, 3.0)
    box.sspn.should == [1.5, 1.5]
  end
  
  it "should calculate the releative center position" do
    box = Maps::BoundingBox.new(0, 0, 2, 2)
    box.sspn.should == [1, 1]
    box = Maps::BoundingBox.new(5, 5, 15, 15)
    box.sspn.should == [5, 5]
  end
  
  it "should grow the box by percent correctly" do
    box = Maps::BoundingBox.new(0.0, 0.0, 2.0, 2.0)
    box.grow!(100)
    box.coords.should == [-2, -2, 4, 4]
    new_box = box.grow(100)
    new_box.coords.should == [-8, -8, 10, 10]
    box.coords.should == [-2, -2, 4, 4]
  end
end

class Float
  def round(precition)
    precition = 10.0 ** (precition)
    (self * precition).floor / precition
  end
end

describe Maps do
  it "should calculate the zoom levels" do
    Maps.resolution(0).round(4).should == 156543.0339.round(4)
    Maps.resolution(1).round(4).should == 78271.5169.round(4)
    Maps.resolution(2).round(4).should == 39135.7584.round(4)
    Maps.resolution(3).round(4).should == 19567.8792.round(4)
    Maps.resolution(4).round(4).should == 9783.9396.round(4)
    Maps.resolution(5).round(4).should == 4891.9698.round(4)
    Maps.resolution(6).round(4).should == 2445.9849.round(4)
    Maps.resolution(7).round(4).should == 1222.9924.round(4)
    Maps.resolution(8).round(4).should == 611.4962.round(4)
    Maps.resolution(9).round(4).should == 305.7481.round(4)
    Maps.resolution(10).round(4).should == 152.8740.round(4)
    Maps.resolution(11).round(4).should == 76.4370.round(4)
    Maps.resolution(12).round(4).should == 38.2185.round(4)
    Maps.resolution(13).round(4).should == 19.1092.round(4)
    Maps.resolution(14).round(4).should == 9.5546.round(4)
    Maps.resolution(15).round(4).should == 4.7773.round(4)
    Maps.resolution(16).round(4).should == 2.3886.round(4)
    Maps.resolution(17).round(4).should == 1.1943.round(4)
    Maps.resolution(18).round(4).should == 0.5972.round(4)
    Maps.resolution(19).round(4).should == 0.2986.round(4)
    Maps.resolution(20).round(4).should == 0.1493.round(4)
    Maps.resolution(21).round(4).should == 0.0746.round(4)
  end
  
  it "should calculate the map size" do
    Maps.map_size(0).should == [256, 256]
    Maps.map_size(10).should == [4 ** 9, 4 ** 9]
    Maps.map_size(20).should == [4 ** 14, 4 ** 14]
  end
  
  it "should calculate the tile xy to pixel xy and vice versa" do
    Maps.pixel2tile(1024, 1024).should == [4, 4]
    Maps.pixel2tile(0, 0).should == [0, 0]
    Maps.tile2pixel(4, 4).should == [1024, 1024]
    Maps.tile2pixel(0, 0).should == [0, 0]
  end
  
  it "should clip correctly as defined by boundings" do
    Maps.clip(45, 40, 50).should == 45
    Maps.clip(45, 45, 50).should == 45
    Maps.clip(45, 50, 55).should == 50
    Maps.clip(45, 30, 40).should == 40
    Maps.clip(45, 40, 45).should == 45
  end
  
  it "should calculate the shift correctly" do
    lat, lng = Maps.shift_latlng(47.99997, 8.00002, 20, 20, 14)
    lat.round(5).should == 47.99882
    lng.round(5).should == 8.00173
  end
  
  it "should calc pixel to lat/lng and vice versa" do
    px, py = Maps.latlng2pixel(47.99997, 8.00002, 14)
    px.should == 2_190_359
    py.should == 1_458_001
    lat, lng = Maps.pixel2latlng(px, py, 14)
    lat.round(5).should == 47.99997
    lng.round(5).should == 8.00002
  end

  it "should return bounding boxes for tile coordinates" do
    bb = Maps.bounding_box(0, 0, 0)
    bb.top.round(8).should == Maps::MAX_LATITUDE
    bb.left.round(8).should == Maps::MIN_LONGITUDE
    bb.bottom.round(8).should == -84.92832093
    bb.right.round(8).should == 178.59375
    
    bb = Maps.bounding_box(1024, 1024, 14)
    bb.top.round(8).should == 82.67628497
    bb.left.round(8).should == -157.5
    bb.bottom.round(8).should == 82.67348347
    bb.right.round(8).should == -157.47802735
  end
end