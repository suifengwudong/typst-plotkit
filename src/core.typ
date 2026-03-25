#import "@preview/cetz:0.4.2"
#import "@preview/cetz-plot:0.1.3": plot
#import cetz.draw: *

#let format-float(num, decimals) = {
  let sign = if num < 0 { "-" } else { "" }
  num = calc.abs(num)
  let int-part = calc.floor(num)
  let frac-part = num - int-part
  let frac-str = ""
  for _ in range(decimals) {
    frac-part *= 10
    let digit = calc.floor(frac-part)
    frac-str += str(digit)
    frac-part -= digit
  }
  if decimals > 0 {
    sign + str(int-part) + "." + frac-str
  } else {
    sign + str(int-part)
  }
}

#let auto_decimals(range) = {
  if range > 100 { 0 } else if range > 10 { 1 } else if range > 1 { 2 } else { 3 }
}

#let bounds_from_points(points) = {
  if points.len() == 0 {
    (x-min: 0, x-max: 1, y-min: 0, y-max: 1)
  } else {
    let xs = points.map(((x, y)) => x)
    let ys = points.map(((x, y)) => y)
    (x-min: calc.min(..xs), x-max: calc.max(..xs), y-min: calc.min(..ys), y-max: calc.max(..ys))
  }
}

#let expand_bounds(bounds, padding: 0.1) = {
  let x-range = bounds.x-max - bounds.x-min
  let y-range = bounds.y-max - bounds.y-min
  let px = if x-range == 0 { 1 } else { padding * x-range }
  let py = if y-range == 0 { 1 } else { padding * y-range }
  (
    x-min: bounds.x-min - px,
    x-max: bounds.x-max + px,
    y-min: bounds.y-min - py,
    y-max: bounds.y-max + py,
  )
}

#let chart(
  layers: (),
  x-label: $x$,
  y-label: $y$,
  size: (12, 8),
  x-min: auto,
  x-max: auto,
  y-min: auto,
  y-max: auto,
  padding: 0.1,
) = {
  // 自动 bounds：从所有含 points 的 layer 里聚合
  let points-acc = ()
  for layer in layers {
    if "points" in layer and layer.points != none {
      for p in layer.points { points-acc.push(p) }
    }
  }

  let base-bounds = bounds_from_points(points-acc)
  let padded = expand_bounds(base-bounds, padding: padding)

  let plot-x-min = if x-min != auto { x-min } else { padded.x-min }
  let plot-x-max = if x-max != auto { x-max } else { padded.x-max }
  let plot-y-min = if y-min != auto { y-min } else { padded.y-min }
  let plot-y-max = if y-max != auto { y-max } else { padded.y-max }

  let x-range = plot-x-max - plot-x-min
  let y-range = plot-y-max - plot-y-min
  let x-decimals = auto_decimals(x-range)
  let y-decimals = auto_decimals(y-range)

  cetz.canvas({
    import cetz.draw: *

    plot.plot(
      size: size,
      x-label: x-label,
      y-label: y-label,
      x-min: plot-x-min,
      x-max: plot-x-max,
      y-min: plot-y-min,
      y-max: plot-y-max,
      x-format: (x) => format-float(x, x-decimals),
      y-format: (y) => format-float(y, y-decimals),
      {
        // 调用 layer 的 render 钩子
        for layer in layers {
          if "render" in layer {
            (layer.render)(plot-x-min, plot-x-max, plot-y-min, plot-y-max)
          }
        }
      },
    )
  })
}
