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

// Expand a single axis range, with log-space padding when mode == "log".
// Returns a 2-tuple (expanded-min, expanded-max).
// Panics with a clear message if log mode is requested but val-min <= 0.
#let expand-axis(val-min, val-max, mode, padding-ratio, axis-name) = {
  if mode == "log" {
    if val-min <= 0 {
      panic(
        "typst-plotkit: " + axis-name + "-mode=\"log\" requires all data values to be positive, " +
        "but the auto-computed " + axis-name + "-min = " + str(val-min) + ". " +
        "Please set " + axis-name + "-min and " + axis-name + "-max manually, " +
        "or remove non-positive values from your data."
      )
    }
    let lmin = calc.log(val-min, base: 10)
    let lmax = calc.log(val-max, base: 10)
    let lr = if lmax == lmin { 1 } else { padding-ratio * (lmax - lmin) }
    (calc.pow(10, lmin - lr), calc.pow(10, lmax + lr))
  } else {
    let r = val-max - val-min
    let p = if r == 0 { 1 } else { padding-ratio * r }
    (val-min - p, val-max + p)
  }
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
  // Axis style: one of "scientific", "scientific-auto", "school-book", "left", none, or auto
  axis-style: auto,
  // Legend: auto (show when labels exist), none (hide), or a coordinate
  legend: auto,
  legend-anchor: auto,
  legend-style: (:),
  // Grid: false, true, "major", "minor", "both"
  // Shorthand `grid:` sets both x-grid and y-grid simultaneously
  x-grid: false,
  y-grid: false,
  grid: none,
  // Axis scaling: "lin" or "log"
  x-mode: "lin",
  y-mode: "lin",
  // Log base (only used when mode is "log")
  x-base: 10,
  y-base: 10,
) = {
  // Apply grid shorthand: if `grid` is set, it overrides both x-grid and y-grid
  let eff-x-grid = if grid != none { grid } else { x-grid }
  let eff-y-grid = if grid != none { grid } else { y-grid }

  // Aggregate bounds from all layers:
  // - layers with `points` contribute via bounds_from_points
  // - layers with an explicit `bounds` dict contribute directly
  let all-bounds = ()
  for layer in layers {
    if "points" in layer and layer.points != none and layer.points.len() > 0 {
      all-bounds.push(bounds_from_points(layer.points))
    }
    if "bounds" in layer and layer.bounds != none {
      all-bounds.push(layer.bounds)
    }
  }

  let base-bounds = if all-bounds.len() == 0 {
    (x-min: 0, x-max: 1, y-min: 0, y-max: 1)
  } else {
    let b = all-bounds.at(0)
    for i in range(1, all-bounds.len()) {
      let eb = all-bounds.at(i)
      b = (..b,
        x-min: calc.min(b.x-min, eb.x-min),
        x-max: calc.max(b.x-max, eb.x-max),
        y-min: calc.min(b.y-min, eb.y-min),
        y-max: calc.max(b.y-max, eb.y-max),
      )
    }
    b
  }

  // Compute padded bounds (only when auto is used for that axis)
  let (exp-x-min, exp-x-max) = if x-min == auto or x-max == auto {
    expand-axis(base-bounds.x-min, base-bounds.x-max, x-mode, padding, "x")
  } else {
    (x-min, x-max)
  }
  let (exp-y-min, exp-y-max) = if y-min == auto or y-max == auto {
    expand-axis(base-bounds.y-min, base-bounds.y-max, y-mode, padding, "y")
  } else {
    (y-min, y-max)
  }

  let plot-x-min = if x-min != auto { x-min } else { exp-x-min }
  let plot-x-max = if x-max != auto { x-max } else { exp-x-max }
  let plot-y-min = if y-min != auto { y-min } else { exp-y-min }
  let plot-y-max = if y-max != auto { y-max } else { exp-y-max }

  // Build axis options dict; format functions are only applied for linear axes
  // (log axes are handled natively by cetz-plot)
  let axis-opts = (
    x-label: x-label,
    y-label: y-label,
    x-min: plot-x-min,
    x-max: plot-x-max,
    y-min: plot-y-min,
    y-max: plot-y-max,
    x-grid: eff-x-grid,
    y-grid: eff-y-grid,
    x-mode: x-mode,
    y-mode: y-mode,
    x-base: x-base,
    y-base: y-base,
  )
  if x-mode != "log" {
    let x-dec = auto_decimals(plot-x-max - plot-x-min)
    axis-opts = (..axis-opts, x-format: (x) => format-float(x, x-dec))
  }
  if y-mode != "log" {
    let y-dec = auto_decimals(plot-y-max - plot-y-min)
    axis-opts = (..axis-opts, y-format: (y) => format-float(y, y-dec))
  }

  // axis-style is only forwarded when explicitly set (otherwise cetz-plot uses its default)
  let style-opt = if axis-style != auto { (axis-style: axis-style) } else { (:) }

  cetz.canvas({
    import cetz.draw: *

    plot.plot(
      ..axis-opts,
      ..style-opt,
      size: size,
      legend: legend,
      legend-anchor: legend-anchor,
      legend-style: legend-style,
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
