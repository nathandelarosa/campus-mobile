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

class MapQuery {
  /// NetworkHelper and endpoint to get data from the external server
  final NetworkHelper _networkHelper = NetworkHelper();
  final String baseEndpoint =
      "https://0dakeo6qfi.execute-api.us-west-2.amazonaws.com/qa/v2/map/search";

  /// Create hook that retrieves and provides map location data in a MapSearchModel schema
  /// @return UseQueryResult - flutter hook that updates asynchronously
  UseQueryResult<List<MapSearchModel>, dynamic> useFetchMapSearchModel() {
    return useQuery(
      ['mapSearchModel'],
      () async {
        final sbcHook = useFetchMapSearchBarController();

        /// fetch data
        List<MapSearchModel> mapSearchModels = [];
        String? _response = await _networkHelper.fetchData(
            baseEndpoint + '?query=' + sbcHook.data!.text + '&region=0');

        /// parse data
        final mapSearchModel = mapSearchModelFromJson(_response!);

        /// make necessary changes for map functionality
        populateDistances();
        reorderLocations();
        addMarker(0);
        updateSearchHistory(sbcHook.data!.text);

        return mapSearchModel;
      },
    );
  }

  /// Create hook that contains an instance of SearchBarController
  /// @return UseQueryResult - flutter hook that updates asynchronously
  UseQueryResult<TextEditingController, dynamic>
      useFetchMapSearchBarController() {
    return useQuery(
      ['mapSearchBarController'],
      () async {
        /// create data
        TextEditingController searchBarController = TextEditingController();

        return searchBarController;
      },
    );
  }

  /// Create hook that contains an instance of Coordinates?
  /// @return UseQueryResult - flutter hook that updates asynchronously
  UseQueryResult<Coordinates?, dynamic> useFetchMapCoordinates() {
    return useQuery(
      ['mapCoordinates'],
      () async {
        /// create data
        Coordinates? coordinates;

        return coordinates;
      },
    );
  }

  /// Create hook that contains an instance of Markers
  /// @return UseQueryResult - flutter hook that updates asynchronously
  UseQueryResult<Map<MarkerId, Marker>, dynamic> useFetchMapMarkers() {
    return useQuery(
      ['mapMarkers'],
      () async {
        /// create data
        Map<MarkerId, Marker> markers = Map<MarkerId, Marker>();

        return markers;
      },
    );
  }

  /// Create hook that contains an instance of GoogleMapController?
  /// @return UseQueryResult - flutter hook that updates asynchronously
  UseQueryResult<GoogleMapController?, dynamic> useFetchMapController() {
    return useQuery(
      ['mapController'],
      () async {
        /// create data
        GoogleMapController? mapController;

        return mapController;
      },
    );
  }

  /// Create hook that contains the searchHistory list
  /// @return UseQueryResult - flutter hook that updates asynchronously
  UseQueryResult<List<String>, dynamic> useFetchMapHistory() {
    return useQuery(
      ['mapHistory'],
      () async {
        /// create data
        List<String> searchHistory = [];

        return searchHistory;
      },
    );
  }

  void addMarker(int listIndex) {
    final queryClient = useQueryClient();

    final Marker marker = Marker(
      markerId: MarkerId(_mapSearchModels[listIndex].mkrMarkerid.toString()),
      position: LatLng(_mapSearchModels[listIndex].mkrLat!,
          _mapSearchModels[listIndex].mkrLong!),
      infoWindow: InfoWindow(
          title: _mapSearchModels[listIndex].title,
          snippet: _mapSearchModels[listIndex].description),
    );

    queryClient.setQueryData<List<AvailabilityModel>>(['availability'],
        (previous) {
      if (oldIndex < newIndex)
        previous!.insert(newIndex - 1, previous.removeAt(oldIndex));
      else //oldIndex > newIndex
        previous!.insert(newIndex, previous.removeAt(oldIndex));
      return previous;
    });

    _markers.clear();
    _markers[marker.markerId] = marker;

    updateMapPosition();
  }

  void updateMapPosition() {
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

  void reorderLocations() {
    _mapSearchModels.sort((MapSearchModel a, MapSearchModel b) {
      if (a.distance != null && b.distance != null) {
        return a.distance!.compareTo(b.distance!);
      }
      return 0;
    });
  }

  void removeFromSearchHistory(String item) {
    searchHistory.remove(item);
    notifyListeners();
  }

  void populateDistances() {
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
}
