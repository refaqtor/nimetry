import
  nimetry,
  math

var
  data: Dataset
  p: Plot = newPlot(720, 480)

for x in 0..10:
  data.add((x: float(x), y: pow(float(x), 2)))

p.setX(0, 11)
p.setY(0, 100)

p.setXtic(1)
p.setYtic(10)

p.addGraph(data, Bar, rgba(167, 184, 211, 255))

p.setFontTtf("fonts/Vera.ttf")
p.setTitle("Bar Graph")

p.save("test3.png")
