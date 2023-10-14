import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/hooks/map_query.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DirectionsButton extends HookWidget {
  const DirectionsButton({
    Key? key,
    required GoogleMapController? mapController,
  })  : _mapController = mapController,
        super(key: key);

  final GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    // Hooks for map feature
    final mapQuery = MapQuery();
    final sbcHook = mapQuery.useFetchMapSearchBarController();
    final coordsHook = mapQuery.useFetchMapCoordinates();
    final markersHook = mapQuery.useFetchMapMarkers();

    return FloatingActionButton(
      heroTag: "directions",
      child: Icon(
        Icons.directions_walk,
        color: Colors.lightBlue,
      ),
      backgroundColor: Colors.white,
      onPressed: () {
        if (coordsHook.data!.lat == null || coordsHook.data!.lon == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Please turn your location on in order to use this feature.'),
            duration: Duration(seconds: 3),
          ));
        } else {
          String locationQuery = sbcHook.data!.text;
          if (locationQuery.isNotEmpty) {
            getDirections(context, markersHook.data!);
          } else {
            Navigator.pushNamed(context, RoutePaths.MapSearch);
          }
        }
      },
    );
  }

  Future<void> getDirections(
      BuildContext context, Map<MarkerId, Marker> markers) async {
    LatLng currentPin = markers.values.toList()[0].position;
    double lat = currentPin.latitude;
    double lon = currentPin.longitude;

    String googleUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon&travelmode=walking';
    String appleUrl = 'http://maps.apple.com/?daddr=$lat,$lon&dirflag=w';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else if (await canLaunch(appleUrl)) {
      await launch(appleUrl);
    } else {
      throw 'Could not launch $googleUrl';
    }
  }
}
