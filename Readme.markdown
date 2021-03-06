# MapKit & TileKit

MapKit and TileKit are tools to help you develop a tile rendering service in
ruby. If you need to draw many markers in google maps then the performance
limit is reached fast. Google has advices to use up to 20 markers at a time.
With some tricks you can inrease the number of markes but with the cost of
inprintability.

If you want to take the full power of google maps you might have to render
your own tile over the tiles of google. Like layers where your layer is on top
of googles.

The system is very simple. You have to add a new Layer to your Google Maps that
request a tile with X, Y and Z like this:

    var layer = new GTileLayer(null, 0, 21, {
      isPng: true,
      opacity: 1
    });
    layer.getTileUrl = function(tile, zoom) {
      return "" + zoom + "/" + tile.x + "/" + tile.y + ".png";
    }
    map.addOverlay(new GTileLayerOverlay(layer));

Once this is done, google starts to request tiles from your server. To
implement the server you need to decode X (tile x), Y (tile y) and
Z (zoom level) to a bounding box of latitude and longitude so that you can
check what to draw in the tile that was requested. After you have fetched some
points you have to draw them in the Tile. This is where TileKit comes into play.
TileKit relies on rmagick a well known image rendering library.

    # this example assumes that a request with x, y and z was done
    # by the browser and saved into x, y, z

    POI = TileKit::Icon.new("images/poi.png", [20, 20], [3, 20], [0, 0, 20, 17])
    bounding_box = MapKit.bounding_box(x, y, z)

    # search for points_of_interest in a bigger bouning box (grow by 10%)
    points = DB.points(bounding_box.grow(10))

    unless points.empty?
      # cerate tile
      tile = TileKit::Image.new(bounding_box)

      # draw icons at point positions
      for point in points do
        tile.draw_icon(point, POI)
      end

      # return tile
      return tile.png
    end

To get an overview on the whole story checkout the sample application in the
example directory. It requires json, sequel, sqlite3 and sinatra.

## Get started with an example

To try the example do the following, clone the git repository:

    cd mapkit
    bundle
    cd example
    ruby start.rb

Then go to the webbrowser at http://localhost:4567/ and try it out. You will
see, how the tiles are rendered from the small sqlite database using rmagick.
