# line_animator
Interpolator for LatLngs (possibly pairs of doubles) that returns a list of points and an angle and current point.

At its heart it simply takes a list of points, creates a set of percentages for the distance between each point, so it can interpolate without changing speed
if the distance between points changes.

The widget can take a callback at controller/animator state changes or after each interpolation update.
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
  this.isReversed 
  })
  ```

Or you can call the class whenever you want, and it will return a point, the list of points built so far (so you can simply use this as a polyline list to flutter_map for example)
It also returns an angle.
```
PointInterpolator({this.originalPoints, this.distanceFunc, this.isReversed})
```

If you set isReversed to 1, it will rebuilt the list in reversed order and animate that way.

It can also take a custom function for calculating distance, the default it will use is haversine.

The angle is the "heading", so we can orientate a marker or something. Example uses an aeroplane that changes heading.

You should be able to either use the LineAnimator() Widget (see examples folder until I've updated this properly!)

Or if you just want to control the interpolator direct without a widget, you can call PointInterpolator() (See the main lib/line_animator example of how the LineAnimator widget accesses PointInterpolator.
and specifically the startAnimation() method)

If you use the class direct, you will have to use your own controller/tweener.


