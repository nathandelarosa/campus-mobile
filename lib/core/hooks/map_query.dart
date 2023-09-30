import 'dart:core';
import 'dart:ffi';
import 'dart:math';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:campus_mobile_experimental/core/models/map.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Custom hook to manage a stateful variable
MapStatefulData useMapStatefulData() {
  final coordinates = useState<Coordinates?>(null);
  final markers = useState<Map<MarkerId, Marker>>(Map<MarkerId, Marker>());
  final searchBarController =
      useState<TextEditingController>(TextEditingController());
  final mapController = useState<GoogleMapController?>(null);
  final searchHistory = useState<List<String>>([]);

  // Expose the stateful data and a function to update it
  return MapStatefulData(
      coordinates.value,
      markers.value,
      searchBarController.value,
      mapController.value,
      searchHistory.value,
      (newCoordinates) => coordinates.value = newCoordinates,
      (markerId, marker) => markers.value[markerId] = marker,
      () => markers.value.clear(),
      (newSearchBarController) =>
          searchBarController.value = newSearchBarController,
      (newMapController) => mapController.value = newMapController,
      (item) => searchHistory.value.add(item),
      (item) => searchHistory.value.remove(item));
}

/// Custom class containing stateful data that is used in many classes
class MapStatefulData {
  Coordinates? coordinates;
  Map<MarkerId, Marker> markers;
  TextEditingController searchBarController;
  GoogleMapController? mapController;
  List<String> searchHistory;

  final Function(Coordinates) setCoordinates;
  final Function(MarkerId, Marker) addMarker;
  final Function() clearMarkers;
  final Function(TextEditingController) setSearchBarController;
  final Function(GoogleMapController) setMapController;
  final Function(String) addSearchHistory;
  final Function(String) removeSearchHistory;

  MapStatefulData(
    this.coordinates,
    this.markers,
    this.searchBarController,
    this.mapController,
    this.searchHistory,
    this.setCoordinates,
    this.addMarker,
    this.clearMarkers,
    this.setSearchBarController,
    this.setMapController,
    this.addSearchHistory,
    this.removeSearchHistory,
  );
}

void addMarker(int listIndex, List<MapSearchModel> _mapSearchModels) {
  final mapStatefulData = useMapStatefulData();
  final Marker marker = Marker(
    markerId: MarkerId(_mapSearchModels[listIndex].mkrMarkerid.toString()),
    position: LatLng(_mapSearchModels[listIndex].mkrLat!,
        _mapSearchModels[listIndex].mkrLong!),
    infoWindow: InfoWindow(
        title: _mapSearchModels[listIndex].title,
        snippet: _mapSearchModels[listIndex].description),
  );
  mapStatefulData.clearMarkers;
  mapStatefulData.addMarker(marker.markerId, marker);

  updateMapPosition();
}

void updateMapPosition() {
  final mapStatefulData = useMapStatefulData();
  final _markers = mapStatefulData.markers;
  final _mapController = mapStatefulData.mapController;

  if (_markers.isNotEmpty && _mapController != null) {
    _mapController!
        .animateCamera(
            CameraUpdate.newLatLng(_markers.values.toList()[0].position))
        .then((_) async {
      await Future.delayed(Duration(seconds: 1));
      try {
        _mapController!
            .showMarkerInfoWindow(_markers.values.toList()[0].markerId);
      } catch (e) {}
    });
  }
}

void reorderLocations(List<MapSearchModel> _mapSearchModels) {
  _mapSearchModels.sort((MapSearchModel a, MapSearchModel b) {
    if (a.distance != null && b.distance != null) {
      return a.distance!.compareTo(b.distance!);
    }
    return 0;
  });
}

void removeFromSearchHistory(String item) {
  final mapStatefulData = useMapStatefulData();
  mapStatefulData.removeSearchHistory(item);
}

void populateDistances(List<MapSearchModel> _mapSearchModels) {
  /// Default coordinates for Price Center
  double? _defaultLat = 32.87990969506536;
  double? _defaultLong = -117.2362059310055;

  /// Get stateful data
  final mapStatefulData = useMapStatefulData();
  Coordinates? _coordinates = mapStatefulData.coordinates;

  double? latitude =
      _coordinates!.lat != null ? _coordinates!.lat : _defaultLat;
  double? longitude =
      _coordinates!.lon != null ? _coordinates!.lon : _defaultLong;
  if (_coordinates != null) {
    for (MapSearchModel model in _mapSearchModels) {
      if (model.mkrLat != null && model.mkrLong != null) {
        var distance = calculateDistance(
            latitude!, longitude!, model.mkrLat!, model.mkrLong!);
        model.distance = distance as double?;
      }
    }
  }
}

num calculateDistance(double lat1, double lng1, double lat2, double lng2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lng2 - lng1) * p)) / 2;
  return 12742 * asin(sqrt(a)) * 0.621371;
}

void updateSearchHistory(String location) {
  final mapStatefulData = useMapStatefulData();
  final _searchHistory = mapStatefulData.searchHistory;

  if (!_searchHistory.contains(location)) {
    // Check to see if this search is already in history...
    mapStatefulData.addSearchHistory(location); // ...If it is not, add it...
  } else {
    // ...otherwise...
    mapStatefulData.removeSearchHistory(
        location); // ...reorder search history to put it back on top
    mapStatefulData.addSearchHistory(location);
  }
}

String getSearchBarControllerText() {
  final mapStatefulData = useMapStatefulData();
  return mapStatefulData.searchBarController.text;
}

/// NetworkHelper and endpoint to get data from the external server
final NetworkHelper _networkHelper = NetworkHelper();
final String baseEndpoint =
    "https://0dakeo6qfi.execute-api.us-west-2.amazonaws.com/qa/v2/map/search";

/// Create hook that retrieves and provides map location data in a 'MapSearchModel' schema
/// @return UseQueryResult - flutter hook that updates asynchronously
UseQueryResult<List<MapSearchModel>, dynamic> useFetchMapModel() {
  return useQuery(
    ['map'],
    () async {
      /// fetch data
      String location = getSearchBarControllerText();
      String? _response = await _networkHelper
          .fetchData(baseEndpoint + '?query=' + location + '&region=0');

      /// parse data
      final data = mapSearchModelFromJson(_response!);

      /// make necessary changes for map functionality
      populateDistances(data);
      reorderLocations(data);
      addMarker(0, data);
      updateSearchHistory(location);

      return data;
    },
  );
}
