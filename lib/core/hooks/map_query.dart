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
  final coordinates = useState<Coordinates>(Coordinates());
  final markers = useState<Map<MarkerId, Marker>>(Map<MarkerId, Marker>());
  final searchBarController =
      useState<TextEditingController>(TextEditingController());
  final mapController =
      useState<GoogleMapController>(GoogleMapController as GoogleMapController);

  // Expose the stateful data and a function to update it
  return MapStatefulData(
      coordinates.value,
      markers.value,
      searchBarController.value,
      mapController.value,
      (newCoordinates) => coordinates.value = newCoordinates,
      (newMarkers) => markers.value = newMarkers,
      (newSearchBarController) =>
          searchBarController.value = newSearchBarController,
      (newMapController) => mapController.value = newMapController);
}

class MapStatefulData {
  Coordinates? coordinates;
  Map<MarkerId, Marker> markers;
  TextEditingController searchBarController;
  GoogleMapController? mapController;

  final Function(Coordinates) setCoordinates;
  final Function(Map<MarkerId, Marker>) setMarkers;
  final Function(TextEditingController) setSearchBarController;
  final Function(GoogleMapController) setMapController;

  MapStatefulData(
      this.coordinates,
      this.markers,
      this.searchBarController,
      this.mapController,
      this.setCoordinates,
      this.setMarkers,
      this.setSearchBarController,
      this.setMapController);
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
    () async {},
  );
}
