import 'package:campus_mobile_experimental/core/hooks/map_query.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';
import 'package:provider/provider.dart';

class QuickSearchIcons extends HookWidget {
  const QuickSearchIcons({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapQuery = MapQuery();
    final queryClient = useQueryClient();
    final sbcHook = mapQuery.useFetchMapSearchBarController();
    final coordsHook = mapQuery.useFetchMapCoordinates();
    final markersHook = mapQuery.useFetchMapMarkers();
    final mcHook = mapQuery.useFetchMapController();
    final shHook = mapQuery.useFetchMapHistory();
    final msmHook = mapQuery.useFetchMapSearchModel(queryClient, sbcHook.data!,
        coordsHook.data, markersHook.data, mcHook.data, shHook.data);

    return Card(
      margin: EdgeInsets.all(5),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            LabeledIconButton(
              icon: Icons.local_parking,
              text: 'Parking',
              onPressed: () {
                mapQuery.setSearchBarController('Parking', queryClient);
                msmHook.refetch();
                Navigator.pop(context);
              },
            ),
            LabeledIconButton(
              icon: Icons.coronavirus_outlined,
              text: 'COVID Tests',
              onPressed: () {
                mapQuery.setSearchBarController('COVID Test Kits', queryClient);
                msmHook.refetch();
                Navigator.pop(context);
              },
            ),
            LabeledIconButton(
              icon: Icons.local_drink,
              text: 'Hydration',
              onPressed: () {
                mapQuery.setSearchBarController('Hydration', queryClient);
                msmHook.refetch();
                Navigator.pop(context);
              },
            ),
            LabeledIconButton(
              icon: Icons.local_atm,
              text: 'ATM',
              onPressed: () {
                mapQuery.setSearchBarController('ATM', queryClient);
                msmHook.refetch();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class LabeledIconButton extends StatelessWidget {
  final IconData? icon;
  final String? text;
  final Function? onPressed;
  LabeledIconButton({this.icon, this.text, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        MaterialButton(
          onPressed: onPressed as void Function()?,
          color: Colors.red,
          textColor: Colors.white,
          child: Icon(
            icon,
            size: 28,
          ),
          padding: EdgeInsets.all(12),
          shape: CircleBorder(),
        ),
        SizedBox(height: 6),
        Text(text!),
      ],
    );
  }
}
