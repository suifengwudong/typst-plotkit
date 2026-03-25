#import "../plotkit.typ": chart, points, smooth, xy

= Log–log plot with grid

// Bode-plot-like data: gain drops with frequency
#let freqs = (1, 2, 5, 10, 20, 50, 100, 200, 500, 1000)
#let gains = (100, 98, 90, 71, 45, 20, 10, 5, 2, 1)

#figure(
  chart(
    layers: (
      points(xy(freqs, gains), color: black, size: 0.15),
      smooth(xy(freqs, gains), color: blue, width: 1.5pt, label: [Gain]),
    ),
    x-label: [Frequency (Hz)],
    y-label: [Gain],
    x-mode: "log",
    y-mode: "log",
    grid: "both",
    size: (12, 7),
  ),
  caption: [Log–log plot with major+minor grid lines],
)
