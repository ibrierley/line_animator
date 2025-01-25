import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:line_animator/line_animator.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import './data.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Line Animator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}


class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {

  List<LatLng> builtPoints = [];
  double markerAngle = 0;
  LatLng markerPoint = LatLng(0,0);
  late List<LatLng> points;
  bool isReversed = false;
  ValueNotifier<LatLng> latLng = ValueNotifier<LatLng>(LatLng(0,0));

  @override
  void initState() {
    points = getPoints(0);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
        ),
        body: LineAnimator(
            originalPoints: points,
            builtPoints: builtPoints,
            duration: Duration(seconds: 5),
            isReversed: isReversed,
            interpolateBetweenPoints: true,
            stateChangeCallback: (status, pointList) {
              if(status == AnimationStatus.completed) {
                WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {isReversed = !isReversed;}));
              }
            },
            duringCallback: (newPoints, point, angle, tweenVal) {
              builtPoints = newPoints;
              markerPoint = point;
              markerAngle = angle;
              latLng.value = point; // valuenotifier
              WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
            },

            child: FlutterMap(
                options: MapOptions(
                  initialCenter: const LatLng( 27.456575, 32.9404151),
                  initialZoom: 6,
                  //cameraConstraint: CameraConstraint.containCenter(
                  //  bounds: LatLngBounds.fromPoints([...getPoints(0), ...getPoints(1)]),
                  //),

                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    tileProvider: CancellableNetworkTileProvider(),
                  ),
                  PolylineLayer(
                      polylines: [
                        Polyline(
                            points: builtPoints,
                            strokeWidth: 2,
                            color: Colors.purple
                        ),
                      ]
                  ),
                  MarkerLayer(
                      markers: [
                        Marker(
                          width: 180,
                          height: 180,
                          point: markerPoint,
                          child:
                              Container(
                                child: Transform.rotate(
                                    angle: markerAngle,
                                    child: Icon(
                                        Icons.airplanemode_active_sharp
                                    )
                                ),
                              ),
                        ),
                      ]
                  ),
                ],
            )
        )
    );
  }

  @override
  void didUpdateWidget(MyHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }
}


