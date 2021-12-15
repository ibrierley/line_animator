import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:line_animator/line_animator.dart';
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
  double markerAngle = 0.0;
  LatLng markerPoint = LatLng(0.0,0.0);
  late List<LatLng> points;
  bool isReversed = false;
  ValueNotifier<LatLng> latLng = ValueNotifier<LatLng>(LatLng(0.0,0.0));

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
                WidgetsBinding.instance?.addPostFrameCallback((_) => setState(() {isReversed = !isReversed;}));
              }
            },
            duringCallback: (newPoints, point, angle, tweenVal) {
              builtPoints = newPoints;
              markerPoint = point;
              markerAngle = angle;
              latLng.value = point; // valuenotifier
              WidgetsBinding.instance?.addPostFrameCallback((_) => setState(() {}));
            },

            child: FlutterMap(
                options: MapOptions(
                  bounds: LatLngBounds.fromPoints([...getPoints(0), ...getPoints(1)]),
                  boundsOptions: FitBoundsOptions(padding: EdgeInsets.all(30)),
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  PolylineLayerOptions(
                      polylines: [
                        Polyline(
                            points: builtPoints,
                            strokeWidth: 2.0,
                            color: Colors.purple
                        ),
                      ]
                  ),
                  MarkerLayerOptions(
                      markers: [
                        Marker(
                          width: 180,
                          height: 180,
                          point: markerPoint,
                          builder: (ctx) =>
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

              /* Example using widget/marker refresh only rather than setState
                 on whole widget refreshing the full flutter_map
                 Just be careful of layer/widget ordering when mixing

              nonRotatedChildren: [
                /// 2nd method value notifier, only refresh the widget
                ValueListenableBuilder(
                    valueListenable: latLng,
                    builder: (context, value, widget) {
                      return MarkerLayerWidget(options: MarkerLayerOptions(
                        markers: [
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: value,
                            builder: (ctx) {
                              print("Building $value $markerAngle");
                                return Container(
                                  child: Transform.rotate(
                                      angle: markerAngle,
                                      child: Icon(
                                          Icons.airplanemode_active_sharp
                                      )
                                  ),
                                );
                            }
                          ),
                        ],
                      ));
                    }
                )
              ],
              */
            )
        )
    );
  }

  @override
  void didUpdateWidget(MyHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

}


