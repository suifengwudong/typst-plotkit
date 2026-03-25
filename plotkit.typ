// typst-plotkit: 一个面向“层(layer)”的轻量绘图工具箱
// 目标：同一张散点图底座上叠加多条曲线（拟合直线/平滑曲线/折线），并统一样式参数

// 对外：同时提供“顶层函数”与“命名空间字典”两种用法

#import "src/core.typ": chart
#import "src/layers.typ": points, polyline, smooth, line, fit_linear
#import "src/stats.typ": linreg

#let layer = (
  points: points,
  polyline: polyline,
  smooth: smooth,
  line: line,
  fit-linear: fit_linear,
)

#let stats = (
  linreg: linreg,
)

#let plot = (
  chart: chart,
  layer: layer,
  stats: stats,
)

// 顶层导出（推荐）
#let chart = chart
#let points = points
#let polyline = polyline
#let smooth = smooth
#let line = line
#let fit-linear = fit_linear
#let linreg = linreg
