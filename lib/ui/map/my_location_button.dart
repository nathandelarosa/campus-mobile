import 'package:campus_mobile_experimental/core/hooks/map_query.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MyLocationButton extends HookWidget {
  const MyLocationButton({
    Key? key,
    required GoogleMapController? mapController,
  })  : _mapController = mapController,
        super(key: key);

  final GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    // Hooks for map feature
    final mapQuery = MapQuery();
    final mapCoordinatesHook = mapQuery.useFetchMapCoordinates();

    return FloatingActionButton(
      heroTag: "my_location",
      child: Icon(
        Icons.my_location,
        color: Colors.white,
      ),
      backgroundColor: Colors.lightBlue,
      onPressed: () {
        if (mapCoordinatesHook.data!.lat == null ||
            mapCoordinatesHook.data!.lon == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Please turn your location on in order to use this feature.'),
            duration: Duration(seconds: 3),
          ));
        } else {
          _mapController!.animateCamera(CameraUpdate.newLatLng(LatLng(
              mapCoordinatesHook.data!.lat!, mapCoordinatesHook.data!.lon!)));
        }
      },
    );
  }
}
