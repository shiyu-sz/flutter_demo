import 'package:flutter/material.dart';

import 'package:flutter_demo/google_map/animate_camera.dart';
import 'package:flutter_demo/google_map/lite_mode.dart';
import 'package:flutter_demo/google_map/map_click.dart';
import 'package:flutter_demo/google_map/map_coordinates.dart';
import 'package:flutter_demo/google_map/map_ui.dart';
import 'package:flutter_demo/google_map/marker_icons.dart';
import 'package:flutter_demo/google_map/move_camera.dart';
import 'package:flutter_demo/google_map/padding.dart';
import 'package:flutter_demo/google_map/page.dart';
import 'package:flutter_demo/google_map/place_circle.dart';
import 'package:flutter_demo/google_map/place_marker.dart';
import 'package:flutter_demo/google_map/place_polygon.dart';
import 'package:flutter_demo/google_map/place_polyline.dart';
import 'package:flutter_demo/google_map/scrolling_map.dart';
import 'package:flutter_demo/google_map/snapshot.dart';
import 'package:flutter_demo/google_map/tile_overlay.dart';

final List<GoogleMapExampleAppPage> _allPages = <GoogleMapExampleAppPage>[
  const MapUiPage(),
  const MapCoordinatesPage(),
  const MapClickPage(),
  const AnimateCameraPage(),
  const MoveCameraPage(),
  const PlaceMarkerPage(),
  const MarkerIconsPage(),
  const ScrollingMapPage(),
  const PlacePolylinePage(),
  const PlacePolygonPage(),
  const PlaceCirclePage(),
  const PaddingPage(),
  const SnapshotPage(),
  const LiteModePage(),
  const TileOverlayPage(),
];

/// MapsDemo is the Main Application.
class MapsDemo extends StatelessWidget {
  /// Default Constructor
  const MapsDemo({super.key});

  void _pushPage(BuildContext context, GoogleMapExampleAppPage page) {
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(page.title)),
          body: page,
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GoogleMaps examples')),
      body: ListView.builder(
        itemCount: _allPages.length,
        itemBuilder: (_, int index) => ListTile(
          leading: _allPages[index].leading,
          title: Text(_allPages[index].title),
          onTap: () => _pushPage(context, _allPages[index]),
        ),
      ),
    );
  }
}