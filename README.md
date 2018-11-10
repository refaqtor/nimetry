# Nimetry - Plotting in Pure Nim

This is a WIP, and as such will be changing frequently. [See documentation here](https://ijneb.github.io/nimetry/).

## Example

```nim
var
  data: Dataset
  data2: Dataset
  data3: Dataset

for x in 1..20:
  data3.add((float(x)/2, log10(float(x))+rand(0.2)-0.4))
for x in 0..1000:
  data.add((x: x/100, y: sin(x/100)))
  data2.add((x: x/100, y: log10(x/100)))

var
  p: Plot = newPlot(720, 480)

p.setX(0, 10)
p.setY(-1.5, 1.5)

p.setXtic(1)
p.setYtic(0.25)

p.addGraph(data, Line, rgba(255, 0, 0, 255))
p.addGraph(data2, Line, rgba(0, 0, 255, 255))
p.addGraph(data3, Scatter, rgba(0, 0, 0, 255))

p.setFontTtf("fonts/Vera.ttf")
p.setTitle("Sine and Log10")

p.save("test.png")
```

![output](examples/test.png)
