#import "@preview/cetz-plot:0.1.3": plot
#import "spline.typ": catmull-rom
#import "stats.typ": linreg

#let _stroke(color, width) = (stroke: (color + width))

#let points(
  pts,
  color: black,
  size: 0.2,
  mark: "o",
) = (
  points: pts,
  render: (x-min, x-max, y-min, y-max) => {
    plot.add(
      pts,
      mark: mark,
      mark-style: (fill: color, stroke: none),
      mark-size: size,
      style: (stroke: none),
    )
  },
)

#let polyline(
  pts,
  color: red,
  width: 1pt,
) = (
  points: pts,
  render: (x-min, x-max, y-min, y-max) => {
    plot.add(pts, mark: none, style: _stroke(color, width))
  },
)

#let smooth(
  pts,
  color: red,
  width: 1pt,
  samples: 16,
) = (
  points: pts,
  render: (x-min, x-max, y-min, y-max) => {
    let curve = if pts.len() < 4 { pts } else { catmull-rom(pts, samples-per-segment: samples) }
    plot.add(curve, mark: none, style: _stroke(color, width))
  },
)

#let line(
  a,
  b,
  color: red,
  width: 1pt,
) = (
  points: none,
  render: (x-min, x-max, y-min, y-max) => {
    let p1 = (x-min, a * x-min + b)
    let p2 = (x-max, a * x-max + b)
    plot.add((p1, p2), mark: none, style: _stroke(color, width))
  },
)

#let fit_linear(
  pts,
  color: red,
  width: 1.5pt,
) = {
  let r = linreg(pts)
  (
    points: pts,
    result: r,
    render: (x-min, x-max, y-min, y-max) => {
      if r.a != none and r.b != none {
        let p1 = (x-min, r.a * x-min + r.b)
        let p2 = (x-max, r.a * x-max + r.b)
        plot.add((p1, p2), mark: none, style: _stroke(color, width))
      }
    },
  )
}
