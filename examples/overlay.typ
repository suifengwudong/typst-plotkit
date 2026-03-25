#import "../plotkit.typ": chart, points, polyline, smooth

= overlay demo

#let pts = ((0, 0.10), (1, 0.62), (2, 0.95), (3, 1.25), (4, 2.02))

#figure(
  chart(
    layers: (
      points(pts, color: black),
      polyline(pts, color: rgb("#888"), width: 1pt),
      smooth(pts, color: red, width: 1.5pt),
    ),
    x-label: [x],
    y-label: [y],
    size: (12, 7),
  ),
  caption: [points + polyline + smooth],
)
