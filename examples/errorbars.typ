#import "../plotkit.typ": chart, yerrorbars, smooth, xy, xyyerr

= Error bars demo

#let xs  = (1, 2, 3, 4, 5)
#let ys  = (2.1, 3.9, 6.2, 7.8, 10.1)
#let dys = (0.3, 0.5, 0.4, 0.6, 0.3)

// xyyerr builds the required (x, y, dy) triples from three separate arrays.
// The smooth layer sits behind and uses only (x, y) points via xy().
#figure(
  chart(
    layers: (
      smooth(xy(xs, ys), color: blue.lighten(40%), width: 1pt),
      yerrorbars(xyyerr(xs, ys, dys), color: blue, label: [Measured]),
    ),
    x-label: [x],
    y-label: [y],
    size: (12, 7),
  ),
  caption: [Symmetric y-error bars with a smooth guide line],
)
