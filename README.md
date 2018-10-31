# Nimetry - Plotting in Pure Nim
This is a huge *WIP*.

## Example

```nim
var
  data: Dataset

for x in 0..1000:
  data.add((x: x/100, y: sin(x/100)))

var
  p: Plot = newPlot(720, 480)

p.setX(0, 10)
p.setY(-1.5, 1.5)

p.setXtic(1)
p.setYtic(0.25)

p.setData(data)

p.setFontTtf("fonts/Vera.ttf")
p.setTitle("Sine Curve")

p.save("test.png")
```

![output](examples/test.png)
