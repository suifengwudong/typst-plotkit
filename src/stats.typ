#let sum(xs) = xs.fold(0, (acc, x) => acc + x)

#let linreg(points) = {
  let n = points.len()
  if n < 2 {
    (a: none, b: none, r2: none, s_yx: none, s_a: none, s_b: none)
  } else {
    let xs = points.map(((x, y)) => x)
    let ys = points.map(((x, y)) => y)
    let xbar = sum(xs) / n
    let ybar = sum(ys) / n

    let Sxx = sum(xs.map(x => (x - xbar) * (x - xbar)))
    let Syy = sum(ys.map(y => (y - ybar) * (y - ybar)))
    let Sxy = sum(points.map(((x, y)) => (x - xbar) * (y - ybar)))

    let a = Sxy / Sxx
    let b = ybar - a * xbar

    let resid = points.map(((x, y)) => y - (a * x + b))
    let SSE = sum(resid.map(r => r * r))
    let r2 = if Syy == 0 { 1 } else { 1 - SSE / Syy }

    // 标准误差（n>2 才有意义）
    let s_yx = if n > 2 { calc.sqrt(SSE / (n - 2)) } else { none }
    let s_a = if s_yx != none { s_yx / calc.sqrt(Sxx) } else { none }
    let s_b = if s_yx != none { s_yx * calc.sqrt(1 / n + (xbar * xbar) / Sxx) } else { none }

    (a: a, b: b, r2: r2, s_yx: s_yx, s_a: s_a, s_b: s_b)
  }
}
