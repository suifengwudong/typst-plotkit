#import "../plotkit.typ": chart, points, smooth, xy

= Multi-series with legend

#let xs = (1, 2, 3, 4, 5)
#let ys-a = (2.1, 3.9, 6.2, 7.8, 10.1)
#let ys-b = (1.1, 2.2, 2.9, 4.1, 5.0)

// Tip: give the label to only *one* layer per series to avoid duplicate
// legend entries.  Here we label the points layer and leave smooth unlabelled.
#figure(
  chart(
    layers: (
      points(xy(xs, ys-a), color: blue,  label: [Series A]),
      smooth(xy(xs, ys-a), color: blue,  width: 1.5pt),
      points(xy(xs, ys-b), color: red,   label: [Series B]),
      smooth(xy(xs, ys-b), color: red,   width: 1.5pt),
    ),
    x-label: [x],
    y-label: [y],
    size: (12, 7),
  ),
  caption: [Two data series on one chart with an auto legend],
)
