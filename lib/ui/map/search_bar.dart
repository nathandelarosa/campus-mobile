import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../core/hooks/map_query.dart';

class SearchBar extends HookWidget {
  const SearchBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapQuery = MapQuery();
    final sbcHook = mapQuery.useFetchMapSearchBarController();

    return Card(
      margin: EdgeInsets.all(5),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back),
            padding: EdgeInsets.symmetric(horizontal: 9),
            alignment: Alignment.centerLeft,
            iconSize: 30,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: TextField(
              textInputAction: TextInputAction.search,
              onChanged: (text) {},
              onSubmitted: (text) {
                if (sbcHook.data!.text.isNotEmpty) {
                  // Don't fetch on empty text field
                  Provider.of<MapsDataProvider>(context, listen: false)
                      .fetchLocations(); // Text doesn't need to be sent over because it's already in the controller
                }
                Navigator.pop(context);
              },
              autofocus: true,
              controller:
                  Provider.of<MapsDataProvider>(context).searchBarController,
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
                hintText: 'Search',
              ),
            ),
          ),
          Provider.of<MapsDataProvider>(context)
                  .searchBarController
                  .text
                  .isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    Provider.of<MapsDataProvider>(context, listen: false)
                        .searchBarController
                        .clear();
                    Provider.of<MapsDataProvider>(context, listen: false)
                        .markers
                        .clear();
                  },
                )
              : Container(height: 0)
        ],
      ),
    );
  }
}
