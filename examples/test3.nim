import
  nimetry,
  chroma,
  math

var
  data: seq[Dataset]

for i in 1..20:
  var tempData: Dataset
  for x in 0..1000:
    tempData.add((x: float(x)/100, y: pow(float(x)/100, (float(i)*0.2))))
  data.add(tempData)

var
  p: Plot = newPlot(520, 1080)
  c: int

p.setY(0, 1)
p.setX(0, 1)
p.setYtic(0.05)
p.setXtic(0.1)

for d in data:
  p.addGraph(d, rgba(uint8(10.5*float(c)), 0, 0, 255))
  c += 1

p.setTitle("Powers")
p.setFontSvg("fonts/DejaVuSans.svg")

p.save("test3.png")
