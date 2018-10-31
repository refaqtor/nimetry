import
  nimetry,
  math

var
  data: Dataset

for x in 0..1000:
  data.add((x: x/100, y: sin(x/100)))

var
  p: Plot = Plot(
    width: 720,
    height: 480,
    axes: Axes(
      xmax: 10, xmin: 0,
      ymax: 1.5, ymin: -1.5,
      xtic: 1, ytic: 0.25
    ),
    data: data
  )

p.save("test.png")
