import
  nimetry,
  math

var
  data: Dataset

for x in 0..1000:
  data.add((x: x/100, y: log10(x/100)))

var
  p: Plot = Plot(
    width: 480,
    height: 480,
    axes: Axes(
      xmax: 20, xmin: 0,
      ymax: 2, ymin: -1,
      xtic: 2, ytic: 0.5
    ),
    data: data
  )

p.save("test.png")
