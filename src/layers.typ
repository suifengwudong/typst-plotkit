#import "@preview/cetz-plot:0.1.3": plot
#import "spline.typ": catmull-rom
#import "stats.typ": linreg

#let _stroke(color, width) = (stroke: (color + width))

#let points(
  pts,
  color: black,
  size: 0.2,
  mark: "o",
  label: none,
) = (
  points: pts,
  render: (x-min, x-max, y-min, y-max) => {
    plot.add(
      pts,
      mark: mark,
      mark-style: (fill: color, stroke: none),
      mark-size: size,
      style: (stroke: none),
      label: label,
    )
  },
)

#let polyline(
  pts,
  color: red,
  width: 1pt,
  label: none,
) = (
  points: pts,
  render: (x-min, x-max, y-min, y-max) => {
    plot.add(pts, mark: none, style: _stroke(color, width), label: label)
  },
)

#let smooth(
  pts,
  color: red,
  width: 1pt,
  samples: 16,
  label: none,
) = (
  points: pts,
  render: (x-min, x-max, y-min, y-max) => {
    let curve = if pts.len() < 4 { pts } else { catmull-rom(pts, samples-per-segment: samples) }
    plot.add(curve, mark: none, style: _stroke(color, width), label: label)
  },
)

#let line(
  a,
  b,
  color: red,
  width: 1pt,
  label: none,
) = (
  points: none,
  render: (x-min, x-max, y-min, y-max) => {
    let p1 = (x-min, a * x-min + b)
    let p2 = (x-max, a * x-max + b)
    plot.add((p1, p2), mark: none, style: _stroke(color, width), label: label)
  },
)

#let fit_linear(
  pts,
  color: red,
  width: 1.5pt,
  label: none,
) = {
  let r = linreg(pts)
  (
    points: pts,
    result: r,
    render: (x-min, x-max, y-min, y-max) => {
      if r.a != none and r.b != none {
        let p1 = (x-min, r.a * x-min + r.b)
        let p2 = (x-max, r.a * x-max + r.b)
        plot.add((p1, p2), mark: none, style: _stroke(color, width), label: label)
      }
    },
  )
}

/// Error bars layer. Each point is a 3-tuple `(x, y, dy)` where `dy` is the
/// symmetric y-error. Draws a mark at `(x, y)` and a vertical error bar of
/// ±dy. Only the first point carries the `label` for the legend.
#let yerrorbars(
  pts,
  color: black,
  width: 1pt,
  whisker-size: 0.5,
  mark: "o",
  mark-size: 0.2,
  label: none,
) = {
  // Compute explicit bounds accounting for y ± dy
  let bounds = if pts.len() == 0 {
    none
  } else {
    let xs  = pts.map(((x, y, dy)) => x)
    let ylo = pts.map(((x, y, dy)) => y - dy)
    let yhi = pts.map(((x, y, dy)) => y + dy)
    (
      x-min: calc.min(..xs),
      x-max: calc.max(..xs),
      y-min: calc.min(..ylo),
      y-max: calc.max(..yhi),
    )
  }

  (
    points: none,
    bounds: bounds,
    render: (x-min, x-max, y-min, y-max) => {
      let eb-style = (stroke: color + width)
      let n = pts.len()
      for i in range(n) {
        let (x, y, dy) = pts.at(i)
        // Only attach the legend label to the first errorbar entry
        let lbl = if i == 0 { label } else { none }
        plot.add-errorbar(
          (x, y),
          y-error: dy,
          style: eb-style,
          mark: mark,
          mark-size: mark-size,
          mark-style: (fill: color, stroke: none),
          whisker-size: whisker-size,
          label: lbl,
        )
      }
    },
  )
}
