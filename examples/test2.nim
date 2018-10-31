import
  nimetry,
  chroma,
  random

var
  data: Dataset
  data2: Dataset

randomize()
for x in 0..10:
  data.add((x: float(x), y: 10-rand(5.0)))
  data2.add((x: float(x), y: 10-rand(5.0)))

var
  p: Plot = newPlot(480, 480)

p.addGraph(data, rgba(255, 0, 0, 255))
p.addGraph(data2, rgba(0, 0, 255, 255))

p.setTitle("Random Lines")
p.setFontTtf("fonts/Vera.ttf")

p.save("test2.png")
