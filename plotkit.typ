// typst-plotkit: 一个面向"层(layer)"的轻量绘图工具箱
// 目标：同一张散点图底座上叠加多条曲线（拟合直线/平滑曲线/折线），并统一样式参数

// 对外：同时提供"顶层函数"与"命名空间字典"两种用法

#import "src/core.typ": chart
#import "src/layers.typ": points, polyline, smooth, line, fit_linear, yerrorbars
#import "src/stats.typ": linreg

// ── 数据组织小助手 ───────────────────────────────────────────────────────────

/// 将两列数组 zip 成 (x, y) 点集
/// 示例：xy((1,2,3), (4,5,6)) -> ((1,4), (2,5), (3,6))
#let xy(xs, ys) = xs.zip(ys)

/// 将三列数组 zip 成 (x, y, dy) 三元组（用于 yerrorbars）
/// 示例：xyyerr((1,2,3), (4,5,6), (0.1,0.2,0.3))
#let xyyerr(xs, ys, dys) = xs.zip(ys).zip(dys).map(((xy, dy)) => {
  let (x, y) = xy
  (x, y, dy)
})

// ── 命名空间字典（可选用法） ─────────────────────────────────────────────────

#let layer = (
  points: points,
  polyline: polyline,
  smooth: smooth,
  line: line,
  fit-linear: fit_linear,
  yerrorbars: yerrorbars,
)

#let stats = (
  linreg: linreg,
)

#let plot = (
  chart: chart,
  layer: layer,
  stats: stats,
)

// ── 顶层导出（推荐） ─────────────────────────────────────────────────────────
#let chart = chart
#let points = points
#let polyline = polyline
#let smooth = smooth
#let line = line
#let fit-linear = fit_linear
#let yerrorbars = yerrorbars
#let linreg = linreg
