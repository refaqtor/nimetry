import
  flippy,
  chroma,
  vmath,
  math,
  typography,
  strutils

const
  padding = 45

type
  XY* = tuple[x: float, y: float]
  Interval* = tuple[start: float, stop: float]
  # TODO: make custom dataset type (for only 1-to-1)
  Dataset* = seq[XY]
  Axes = object
    xtic, ytic: float
    xmax, xmin: float
    ymax, ymin: float
  Plot* = ref object
    title: string
    width, height: int
    axes: Axes
    data: Dataset

proc newPlot*(width, height: int): Plot =
  var p = Plot(width: width, height: height)
  return p

proc setTitle*(p: Plot, t: string) =
  p.title = t

proc setX*(p: Plot, start, stop: float) =
  p.axes.xmin = start
  p.axes.xmax = stop

proc setY*(p: Plot, start, stop: float) =
  p.axes.ymin = start
  p.axes.ymax = stop

proc setXtic*(p: Plot, tic: float) =
  p.axes.xtic = tic

proc setYtic*(p: Plot, tic: float) =
  p.axes.ytic = tic

proc setData*(p: Plot, d: seq[XY]) =
  p.data = d

proc alphaWhite(image: var Image) =
  for x in 0..<image.width:
    for y in 0..<image.height:
      var c = image.getrgba(x, y)
      c.r = uint8(255) - c.a
      c.g = uint8(255) - c.a
      c.b = uint8(255) - c.a
      c.a = 255
      image.putrgba(x, y, c)

method save*(p: Plot, fn: string) {.base.} =
  let
    xlen = p.axes.xmax - p.axes.xmin
    ylen = p.axes.ymax - p.axes.ymin
  var
    img = newImage(p.width, p.height, 4)
    font = readFontTtf("fonts/Vera.ttf")
    text = newImage(p.width, padding-2, 4)
  font.size = 10
  img.fill(rgba(255, 255, 255, 255))
  if p.title != "":
    var layout = font.typeset(p.title,
      pos=vec2(0, 0),
      size=vec2(float(p.width), float(padding-2)),
      hAlign=Center,
      vAlign=Middle
    )
    text.drawText(layout)
    text.alphawhite()
    img.blit(
      text,
      rect(0, 0, float(p.width), float(padding-2)),
      rect(0, 0, float(p.width), float(padding-2))
    )
  img.line(
    vec2(padding, padding),
    vec2(padding, float(p.height)-padding),
    rgba(0, 0, 0, 255)
  )
  img.line(
    vec2(padding, float(p.height)-padding),
    vec2(float(p.width)-padding, float(p.height)-padding),
    rgba(0, 0, 0, 255)
  )
  let
    yticJump = (p.axes.ytic/ylen)*(float(p.height)-2*padding)
    yticAmount = int(floor((float(p.height)-2*padding)/yticJump))
  text = newImage(padding-2, p.height, 4)
  for ymult in 0 .. yticAmount:
    img.line(
      vec2(padding-2, float(p.height)-padding-yticJump*float(ymult)),
      vec2(padding+2, float(p.height)-padding-yticJump*float(ymult)),
      rgba(0, 0, 0, 255)
    )
    var layout = font.typeset(formatFloat(p.axes.ymin+p.axes.ytic*float(ymult), ffDecimal, 2),
      pos=vec2(0, float(p.height)-padding-yticJump*float(ymult)-6),
      size=vec2(padding-4, 12),
      hAlign=Right,
      vAlign=Middle
    )
    text.drawText(layout)
  text.alphaWhite()
  img.blit(
    text,
    rect(float(0), float(0), float(padding)-2, float(p.height)),
    rect(float(0), float(0), float(padding)-2, float(p.height))
  )
  let
    xticJump = (p.axes.xtic/xlen)*(float(p.width)-2*padding)
    xticAmount = int(floor((float(p.width)-2*padding)/xticJump))
  text = newImage(p.width, padding-2, 4)
  for xmult in 0 .. xticAmount:
    img.line(
      vec2(float(p.width)-padding-xticJump*float(xmult), float(p.height)-padding+2),
      vec2(float(p.width)-padding-xticJump*float(xmult), float(p.height)-padding-2),
      rgba(0, 0, 0, 255)
    )
    var layout = font.typeset(formatFloat(p.axes.xmin+p.axes.xtic*float(xmult), ffDecimal, 2),
      pos=vec2(xticJump*float(xmult)+padding*0.5, 0),
      size=vec2(float(p.width-padding*2)/float(xticAmount), 12),
      hAlign=Center,
      vAlign=Top
    )
    text.drawText(layout)
  text.alphaWhite()
  img.blit(
    text,
    rect(float(0), float(0), float(p.width), float(padding-2)),
    rect(float(0), float(p.height-padding+6), float(p.width), float(padding-2))
  )
  var
    prevPoint: XY
    count = 0
  for point in p.data:
    if point.x > p.axes.xmin and point.x < p.axes.xmax and
        point.y > p.axes.ymin and point.y < p.axes.ymax:
      let
        offsetPoint: XY = (point.x - p.axes.xmin, point.y - p.axes.ymin)
        newPoint: XY = (
          (offsetPoint.x / (xlen))*(float(p.width)-2*padding),
          (offsetPoint.y / (ylen))*(float(p.height)-2*padding)
        )
      if count != 0:
        img.line(
          vec2(padding+prevPoint.x, (float(p.height)-padding)-prevPoint.y),
          vec2(padding+newPoint.x, (float(p.height)-padding)-newPoint.y),
          rgba(255, 0, 0, 255)
        )
      prevPoint = newPoint
      count += 1
  img.save(fn)