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
  GraphStyle* = enum
    Line, Scatter, Bar
  XY* = tuple[x: float, y: float]
  Dataset* = seq[XY]
  Axes = object
    xtic, ytic: float
    xmax, xmin: float
    ymax, ymin: float
  Graph* = object
    data: Dataset
    style: GraphStyle
    color: ColorRGBA
  Plot* = ref object
    graphs: seq[Graph]
    title: string
    font: Font
    width, height: int
    axes: Axes

proc rgba*(r, g, b, a: uint8): ColorRGBA =
  ColorRGBA(r: r, g: g, b: b, a: a)

proc newPlot*(width = 480, height = 360): Plot =
  var p = Plot(width: width, height: height)
  p.axes.xmin = 0
  p.axes.xmax = 10
  p.axes.ymin = 0
  p.axes.ymax = 10
  p.axes.xtic = 1
  p.axes.ytic = 1
  return p

proc addGraph*(p: Plot, d: Dataset, s: GraphStyle, c: ColorRGBA = rgba(255, 0, 0, 255)) =
  p.graphs.add(Graph(data: d, style: s, color: c))

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

proc setFontTtf*(p: Plot, filename: string) =
  p.font = readFontTtf(filename)

proc setFontSvg*(p: Plot, filename: string) =
  p.font = readFontSvg(filename)

proc alphaWhite(img: var Image) =
  for x in 0..<img.width:
    for y in 0..<img.height:
      var c = img.getRgba(x, y)
      c.r = uint8(255) - c.a
      c.g = uint8(255) - c.a
      c.b = uint8(255) - c.a
      c.a = 255
      img.putrgba(x, y, c)

proc save*(p: Plot, filename: string) =
  let
    xlen = p.axes.xmax - p.axes.xmin
    ylen = p.axes.ymax - p.axes.ymin
  var
    img = newImage(p.width, p.height, 4)
    font = p.font
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
  var
    prevPoint: XY
    count = 0
    supersampled = newImage(2*(p.width-padding*2), 2*(p.height-padding*2), 4)
  supersampled.fill(rgba(255, 255, 255, 255))
  for graph in p.graphs:
    for point in graph.data:
      if point.x >= p.axes.xmin and point.x <= p.axes.xmax and
          point.y >= p.axes.ymin and point.y <= p.axes.ymax:
        let
          offsetPoint: XY = (point.x - p.axes.xmin, point.y - p.axes.ymin)
          newPoint: XY = (
            (offsetPoint.x / (xlen))*float(2*p.width-padding*4),
            (offsetPoint.y / (ylen))*float(2*p.height-padding*4)
          )
        if count != 0:
          case graph.style
          of Line:
            supersampled.line(
              vec2(prevPoint.x, float(p.height*2-padding*4)-prevPoint.y),
              vec2(newPoint.x, float(p.height*2-padding*4)-newPoint.y),
              graph.color
            )
            supersampled.line(
              vec2(prevPoint.x, float(p.height*2-padding*4)-prevPoint.y+1),
              vec2(newPoint.x, float(p.height*2-padding*4)-newPoint.y+1),
              graph.color
            )
            supersampled.line(
              vec2(prevPoint.x+1, float(p.height*2-padding*4)-prevPoint.y),
              vec2(newPoint.x+1, float(p.height*2-padding*4)-newPoint.y),
              graph.color
            )
          of Scatter:
            supersampled.line(
              vec2(newPoint.x, float(p.height*2-padding*4)-newPoint.y-5),
              vec2(newPoint.x, float(p.height*2-padding*4)-newPoint.y+5),
              graph.color
            )
            supersampled.line(
              vec2(newPoint.x-5, float(p.height*2-padding*4)-newPoint.y),
              vec2(newPoint.x+5, float(p.height*2-padding*4)-newPoint.y),
              graph.color
            )
          of Bar:
            let
              barWidth = float(p.height*2-padding*4)/xlen
            for offset in 0..int(floor(barWidth)):
              supersampled.line(
                vec2(newPoint.x+(barWidth/2)-float(offset), float(p.height*2-padding*4)-newPoint.y),
                vec2(newPoint.x+(barWidth/2)-float(offset), float(p.height*2-padding*4)),
                graph.color
              )
        prevPoint = newPoint
        count += 1
    count = 0
  supersampled = supersampled.minify(2)
  blit(
    img,
    supersampled,
    rect(float(0), float(0), float(p.width)-padding*2, float(p.height)-padding*2),
    rect(float(padding), float(padding), float(p.width)-padding*2, float(p.height)-padding*2)
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
    var
      decimals: bool
      number: float
    if p.axes.ytic-floor(p.axes.ytic) == 0:
      decimals = false
    else:
      decimals = true
    number = p.axes.ymin+p.axes.ytic*float(ymult)
    let stringNumber = if decimals: formatFloat(number, ffDecimal, 2) else: $(int(number))
    var layout = font.typeset(
      stringNumber,
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
    var
      decimals: bool
      number: float
    if p.axes.xtic-floor(p.axes.xtic) == 0:
      decimals = false
    else:
      decimals = true
    number = p.axes.xmin+p.axes.xtic*float(xmult)
    let stringNumber = if decimals: formatFloat(number, ffDecimal, 2) else: $(int(number))
    var layout = font.typeset(
      stringNumber,
      pos=vec2(xticJump*float(xmult)+padding-0.5*(float(p.width)-padding*2)/float(xticAmount), 0),
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
  img.save(filename)
