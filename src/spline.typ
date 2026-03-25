// Catmull–Rom 样条插值：按点序生成平滑曲线采样点
#let catmull-rom(points, samples-per-segment: 16) = {
  let n = points.len()
  if n <= 2 {
    points
  } else {
    let out = ()
    for i in range(n - 1) {
      let p0 = if i == 0 { points.at(0) } else { points.at(i - 1) }
      let p1 = points.at(i)
      let p2 = points.at(i + 1)
      let p3 = if i + 2 >= n { points.at(n - 1) } else { points.at(i + 2) }

      let x0 = p0.at(0)
      let y0 = p0.at(1)
      let x1 = p1.at(0)
      let y1 = p1.at(1)
      let x2 = p2.at(0)
      let y2 = p2.at(1)
      let x3 = p3.at(0)
      let y3 = p3.at(1)

      // 每段采样：除最后一段外不包含 t=1，避免点重复
      let steps = if i == n - 2 { samples-per-segment } else { samples-per-segment - 1 }
      for s in range(steps + 1) {
        let t = s / samples-per-segment
        let t2 = t * t
        let t3 = t2 * t

        let x = 0.5 * (
          2 * x1
          + (-x0 + x2) * t
          + (2 * x0 - 5 * x1 + 4 * x2 - x3) * t2
          + (-x0 + 3 * x1 - 3 * x2 + x3) * t3
        )
        let y = 0.5 * (
          2 * y1
          + (-y0 + y2) * t
          + (2 * y0 - 5 * y1 + 4 * y2 - y3) * t2
          + (-y0 + 3 * y1 - 3 * y2 + y3) * t3
        )

        out.push((x, y))
      }
    }
    out
  }
}
