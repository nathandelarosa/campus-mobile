import 'package:campus_mobile_experimental/core/hooks/map_query.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/map/quick_search_icons.dart';
import 'package:campus_mobile_experimental/ui/map/search_bar.dart';
import 'package:campus_mobile_experimental/ui/map/search_history_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';
import 'package:provider/provider.dart';

class MapSearchView extends HookWidget {
  @override
  Widget build(BuildContext context) {
    // Hooks for map feature
    final mapQuery = MapQuery();
    final shHook = mapQuery.useFetchMapHistory();

    return ContainerView(
      child: Column(
        children: <Widget>[
          Hero(
            tag: 'search_bar',
            child: SearchBar(),
          ),
          QuickSearchIcons(),
          shHook.data!.isEmpty
              ? Card(
                  margin: EdgeInsets.all(5),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    child: Center(child: Text('You have no recent searches')),
                  ),
                )
              : SearchHistoryList()
        ],
      ),
    );
  }
}
