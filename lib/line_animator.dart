library line_animator;

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';

class InterpolatedResult {
  LatLng point;
  double angle;
  List<LatLng> builtPoints;
  double animValue;
  double controllerValue;

  InterpolatedResult({required this.point, required this.angle, required this.builtPoints, required this.animValue, required this.controllerValue});
}

class PercentageStep {
  double percent;
  double distance;
  double time;

  PercentageStep({ this.percent=0.0, required this.distance, this.time=10.0 });
}

class PointInterpolator {

  List<LatLng> builtPoints = [];
  List<LatLng> points = [];
  List<LatLng> originalPoints = [];
  Function(LatLng, LatLng)? distanceFunc;
  late List<PercentageStep> pointDistanceSteps;
  int lastPointIndex = 1;
  double totalDistance = 0.0;
  LatLng? _previousPoint;
  late double _lastAngle = 0.0;
  LatLng? interpolatedPoint;
  bool isReversed = false;

  PointInterpolator({ required this.originalPoints, this.distanceFunc, required this.isReversed}) {
    reload();
  }

  void reload() {
    lastPointIndex = 1;
    builtPoints = [];
    points = [];
    buildPointsMap();
  }

  void buildPointsMap() {
    var myDistanceFunc = distanceFunc ?? haversine;

    if(isReversed) {
      points = []..addAll(originalPoints.reversed.toList());
    } else {
      points = []..addAll(originalPoints);
    }

    builtPoints.add(LatLng(points[0].latitude, points[0].longitude));
    builtPoints.add(LatLng(points[0].latitude, points[0].longitude));

    pointDistanceSteps = [PercentageStep(distance: 0.0, percent: 0.0)];

    totalDistance = 0.0;

    /// build up a list of distances that each point must pass before being displayed
    for (var c=0; c < points.length - 1; c++) {
      totalDistance += myDistanceFunc(points[c], points[c+1]);
      pointDistanceSteps.add(PercentageStep(distance: totalDistance, percent: 0.0));     /// Check percent
    }

    /// build a list of percentages now we know the length, for how far the point is along
    for (var c=0; c < points.length ; c++) {
      pointDistanceSteps[c].percent = pointDistanceSteps[c].distance / totalDistance;
    }

  }

  InterpolatedResult interpolate( controllerValue, animValue, interpolateBetweenPoints ) {
    var thisPoint;

    for( var c=lastPointIndex; c < points.length ; c++ ) {
      if( animValue >= pointDistanceSteps[c].distance ) {
        /// Our animation is past the next point, so add it in
        /// but remove any interpolated point that we were using
        if( interpolatedPoint != null ) {
          builtPoints.removeLast(); // dont nec need the interpolated point any more
          interpolatedPoint = null;
        }

        thisPoint = LatLng(points[c].latitude, points[c].longitude);
        builtPoints.add(thisPoint);
        lastPointIndex = c+1;

      } else {

        /// only need this if we want to draw inbetween points...
        /// use our point steps and interpolate
        if( interpolateBetweenPoints ) {

          var lastPerc = pointDistanceSteps[c - 1].percent;
          var nextPerc = pointDistanceSteps[c].percent;

          if (nextPerc == null) break;

          var perc = (controllerValue - lastPerc) / ///  swap this around with not 0-1 and get rid of tweener ?
              (nextPerc - lastPerc);

          var intermediateLat = (points[c].latitude -
              points[c - 1].latitude) * perc + points[c - 1].latitude;
          var intermediateLon = (points[c].longitude -
              points[c - 1].longitude) * perc + points[c - 1].longitude;


          interpolatedPoint = LatLng(
              intermediateLat, intermediateLon); // last tail point

          if (builtPoints.length > c) {
            builtPoints[c] = interpolatedPoint!;
          } else {
            builtPoints.add(interpolatedPoint!);
          }
        }

        thisPoint = interpolatedPoint;
        break;
      }
    }

    if( thisPoint == null ) {
      thisPoint = LatLng(points[lastPointIndex - 1].latitude,
          points[lastPointIndex - 1].longitude);
    }

    double angle = 0.0;
    if(_previousPoint != null)
      if(thisPoint != null) {
        angle = -atan2(thisPoint.latitude - _previousPoint?.latitude,
          thisPoint.longitude - _previousPoint?.longitude ) - 4.7128 ;
    }

    // We do this in case we're not interpolating visually otherwise
    // point and prev point are the same most of the time
    if(_lastAngle == null) _lastAngle = angle;
    if(thisPoint != _previousPoint) _lastAngle = angle;
    //if((_lastAngle == null) || (thisPoint != _previousPoint)) _lastAngle = angle;

    _previousPoint = thisPoint;

    return InterpolatedResult(point: thisPoint, angle: _lastAngle, animValue: animValue,
        controllerValue: controllerValue, builtPoints: builtPoints);
  }

  double haversine(LatLng p1, LatLng p2) {
    var lat1 = p1.latitudeInRad,
        lat2 = p2.latitudeInRad;
    var lon1 = p1.longitudeInRad,
        lon2 = p2.longitudeInRad;

    var earthRadius = 6378137.0; // WGS84 major axis
    double distance = 2 *
        earthRadius *
        asin(sqrt(pow(sin(lat2 - lat1) / 2, 2) +
            cos(lat1) * cos(lat2) * pow(sin(lon2 - lon1) / 2, 2)));

    return distance;
  }
}


class LineAnimator extends StatefulWidget {
  final Widget child;
  final List<LatLng> originalPoints;
  final List<LatLng> builtPoints;
  final Function? distanceFunc;
  final Function? stateChangeCallback;
  final Function? duringCallback;
  final Duration duration;
  final double? begin;
  final double? end;
  final bool isReversed;
  final AnimationController? controller;
  final bool interpolateBetweenPoints;

  const LineAnimator ({ Key? key, required this.duration, required this.child, required this.originalPoints, required this.builtPoints, this.distanceFunc,
    this.duringCallback,  this.stateChangeCallback,
    this.begin=0.0, this.end=1.0, this.controller, this.isReversed=false, this.interpolateBetweenPoints=true }) : super(key: key);

  @override
  _LineAnimatorState createState() => _LineAnimatorState();
}

class _LineAnimatorState extends State<LineAnimator> with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  List<LatLng> builtPoints = [];
  late PointInterpolator interpolator;


  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void initState() {
    controller = AnimationController(duration: widget.duration, vsync: this);
    startAnimation();
    super.initState();
  }

  void startAnimation() {
    interpolator = PointInterpolator(
originalPoints: widget.originalPoints, distanceFunc: null, isReversed: widget.isReversed);

    if( controller == null)
      controller = AnimationController(duration: widget.duration, vsync: this);

    animation = Tween<double>( begin: widget.begin, end: interpolator.totalDistance ).animate(controller)
      ..addListener(() {

        InterpolatedResult interpolatedResult = interpolator.interpolate(controller.value,
            animation.value, widget.interpolateBetweenPoints); /// not sure we need a tween at this point anymore, controller only ?

        if(interpolatedResult.point != null)
          widget.duringCallback?.call(interpolatedResult.builtPoints,
              interpolatedResult.point, interpolatedResult.angle, animation.value);

      })..addStatusListener((status) {
        widget.stateChangeCallback?.call(animation.status, builtPoints);
      });

    controller.forward();
  }

  @override
  void didUpdateWidget(LineAnimator oldWidget) {
    if((oldWidget.begin != widget.begin) ||
        (oldWidget.originalPoints != widget.originalPoints ||
            (oldWidget.isReversed != widget.isReversed))) {
      interpolator.originalPoints = widget.originalPoints;
      interpolator.isReversed = widget.isReversed;
      interpolator.reload();
      controller.reset();
      controller.forward(from: widget.begin);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


}


