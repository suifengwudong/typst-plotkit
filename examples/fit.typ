#import "../plotkit.typ": chart, points, fit-linear

= linear fit demo

#let pts = ((2, 36.93), (3, 55.38), (4, 73.84), (5, 92.29), (6, 110.75), (7, 129.20), (8, 147.67))
#let fit = fit-linear(pts, color: red)

#figure(
  chart(
    layers: (
      points(pts, color: black),
      fit,
    ),
    x-label: [I (mA)],
    y-label: [U_H (mV)],
    size: (12, 7),
  ),
  caption: [linear fit],
)

回归结果：

- $a = #fit.result.a$
- $b = #fit.result.b$
- $R^2 = #fit.result.r2$
