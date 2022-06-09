# Flutter line_animator (for flutter_map, but may work with others)
Interpolator for LatLngs (possibly pairs of doubles) that returns a list of points and an angle and current point.

<img src="https://github.com/ibrierley/line_animator/raw/master/lineanim.gif" width="400" height="800">

So you can animate lines (like polylines, and it will probably work for polygons sort of, anything that takes a latlng list).
Also though, if you just wanted to animate a marker along a line of latlngs (without drawing the line), it should work also.

At its heart it simply takes a list of points, creates a set of percentages for the distance between each point, so it can interpolate without changing speed
if the distance between points changes.

The widget can take a callback at controller/animator state changes (stateChangeCallback) or after each interpolation update (duringCallback).
```
LineAnimator ({ Key key, 
  this.duration, 
  this.child, 
  this.originalPoints, 
  this.builtPoints, 
  this.distanceFunc,
  this.duringCallback,
  this.stateChangeCallback,
  this.begin=0.0, 
  this.end, 
  this.controller, 
  this.interpolateBetweenPoints,
  this.isReversed 
  })
  ```

Or you can call the class whenever you want, and it will return a point, the list of points built so far (so you can simply use this as a polyline list to flutter_map for example)
It also returns an angle.
```
PointInterpolator({this.originalPoints, this.distanceFunc, this.isReversed})
/// then call interpolate() on it. reload() will reload and recalculate the points, if you need (i.e to reverse it)
```

If you set isReversed to 1, it will rebuilt the list in reversed order and animate that way.

It can also take a custom function for calculating distance, the default it will use is haversine.

The angle is the "heading", so we can orientate a marker or image or whatever. Example uses an aeroplane that changes heading.

You should be able to either use the LineAnimator() Widget (see examples folder until I've updated this properly!)

See the main lib/line_animator example of how the LineAnimator widget accesses PointInterpolator. Also examples/lib/flutter_map_line_animator.dart to see it interface with flutter_map (it doesn't need a plugin at all, it just references a list of points)

If you use the class direct, you will have to use your own controller/tweener.

If you don't want smooth interpolation, and just want the line drawn when destination reached and not inbetween, then set interpolateBetweenPoints to false.

Note, the example calls a setState on the whole flutter_map/homepage widget for simplicity. I suspect you may want to see if you can use this as a separate markerwidget child and only setState on that. See the commented out section in the example.



