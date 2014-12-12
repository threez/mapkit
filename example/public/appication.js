var map = null,
    inovex_hq = null,
    inovex_hq_marker = null,
    points_of_interest = new Array(),
    last_cursor = null,
    $map_divs = null;
var inovex_text = "<img src='http://www.inovex.de/images/inovex_logo.gif'><br/><b>Here is the inovex <u>HQ</u></b><br/><br/><a href='http://inovex.de'>inovex</a>";
var aral = new GLatLng(48.901,8.666);
var aral_marker = new GMarker(aral);
var aral_text = "<b>Aral!</b>";
var ggeo = new GClientGeocoder();

function displayAndCenter(map, position, text) {
  map.panTo(position);
  map.openInfoWindowHtml(position, text);
  return false;
}

function start() {
  ggeo.getLatLng("Karlsruherstr. 71, Pforzheim", function(point) {
    inovex_hq = point;
    inovex_hq_marker = new GMarker(inovex_hq);

    initialize();
  });
}

function updatePointsOfInterest() {
  points_of_interest = new Array();
  $map_divs = $("#map div");
  var bounds = map.getBounds(),
      sw = bounds.getSouthWest(),
      ne = bounds.getNorthEast(),
      path = "/" + ne.lat() + "/" + sw.lng() + "/" + sw.lat() +
            "/" + ne.lng() + "/" + map.getZoom() + ".json";
  $.getJSON(path, function(data) {
    var results = data['results'];
    for(var i = 0; i < results.length; i++) {
      var bound = new GLatLngBounds(
        new GLatLng(results[i][2], results[i][1]),
        new GLatLng(results[i][0], results[i][3])
      );
      bound.title = results[i][4];
      bound.address = results[i][5];
      bound.city = results[i][6];
      bound.poi_point = new GLatLng(results[i][7], results[i][8]);

      points_of_interest.push(bound);
    }
  });
}

function initialize() {
  if (GBrowserIsCompatible()) {
    map = new GMap2(document.getElementById("map"));

    // new layer
    var layer = new GTileLayer(null, 0, 21, {
      isPng: true,
      opacity: 1
    });
    layer.getTileUrl = function(tile, zoom) {
      return "" + zoom + "/" + tile.x + "/" + tile.y + ".png";
    }

    map.setCenter(inovex_hq, 12);

    map.addOverlay(inovex_hq_marker);
    map.addOverlay(aral_marker);
    map.addControl(new GLargeMapControl());
    map.addControl(new GMapTypeControl());
    map.enableScrollWheelZoom();

    GEvent.addListener(inovex_hq_marker, "click", function() {
      displayAndCenter(map, inovex_hq, inovex_text);
    });

    GEvent.addListener(aral_marker, "click", function() {
      displayAndCenter(map, aral, aral_text);
    });

    GEvent.addListener(map, "click",
      function(overlay, latlng, overlaylatlng) {

      for (var i = 0; i < points_of_interest.length; i++) {
        if (points_of_interest[i].contains(latlng)) {
          map.openInfoWindowHtml(points_of_interest[i].poi_point,
            points_of_interest[i].title + "<br>" +
            points_of_interest[i].address + "<br>" +
            points_of_interest[i].city);
          break;
        }
      }
    });

    GEvent.addListener(map, "mousemove", function(latlng) {
      var found_one = false;
      for (var i = 0; i < points_of_interest.length; i++) {
        if (points_of_interest[i].contains(latlng)) {
          found_one = true;
          last_cursor = $map_divs.css("cursor");
          $map_divs.css("cursor", "pointer");
          break;
        }
      }
      if (!found_one) $map_divs.css("cursor", "move");
    });

    GEvent.addListener(map, "moveend", updatePointsOfInterest);

    map.addOverlay(new GTileLayerOverlay(layer));
    updatePointsOfInterest();
  }
}