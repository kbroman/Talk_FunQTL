# Interactive lod curve and QTL effect plot
#
# This is awful code; I just barely know what I'm doing.

# function that does all of the work
draw = (data) ->

  # colors
  darkBlue = "darkslateblue"
  lightGray = d3.rgb(230, 230, 230)
  darkGray = d3.rgb(200, 200, 200)
  pink = "hotpink"
  altpink = "#E9CFEC"
  purple = "#8C4374"
  darkRed = "crimson"
  # bgcolor = "black"
  labelcolor = "white"
  titlecolor = "Wheat"
  maincolor = "Wheat"

  # rounding functions
  nodig = d3.format(".0f")
  onedig = d3.format(".1f")
  twodig = d3.format(".2f")

  # dimensions of SVG
  w = [800, 200]
  h = 500
  pad = {left:60, top:30, right:10, bottom: 40, inner: 5}
  totalw = w[0]+w[1]+pad.left*2+pad.right*2
  totalh = h + pad.top + pad.bottom

  # max LOD and min/max phenotype
  minPhe = d3.min(data.phevals)
  maxPhe = d3.max(data.phevals)
  maxLod = 0
  maxLodByChr = {}
  maxLodByChr_marker = {}
  for chr in data.chr
    maxLodByChr[chr] = 0
    maxLodByChr_marker[chr] = ""
    for lod in data.lod[chr].lod
      maxLod = lod if maxLod < lod
    for m of data.markerindex[chr]
      lod = data.lod[chr].lod[data.markerindex[chr][m]]
      if lod > maxLodByChr[chr]
        maxLodByChr[chr] = lod
        maxLodByChr_marker[chr] = m

  bigCircRad = "4"
  medCircRad = "4"
  smCircRad =  "2"
  tinyRad = "1"

  # create svg
  svg = d3.select("div#lod_onetime_fig")
          .append("svg")
          .attr("height", totalh)
          .attr("width", totalw)

  # groups for the two panels, translated to have origin = (0,0)
  lodpanel = svg.append("g").attr("id", "lodpanel")
  effpanel = svg.append("g").attr("id", "effpanel")

  # jitter amounts for PXG plot
  jitterAmount = (w[1])/50
  jitter = []
  for i of data.phevals
    jitter[i] = (2.0*Math.random()-1.0) * jitterAmount

  # gray backgrounds
  lodpanel.append("rect")
          .attr("x", pad.left)
          .attr("y", pad.top)
          .attr("height", h)
          .attr("width", w[0])
          .attr("fill", lightGray)
          .attr("stroke", "black")
          .attr("stroke-width", 1)
  effpanel.append("rect")
          .attr("x", pad.left*2+pad.right+w[0])
          .attr("y", pad.top)
          .attr("height", h)
          .attr("width", w[1])
          .attr("fill", lightGray)
          .attr("stroke", "black")
          .attr("stroke-width", 1)

  # start and end of each chromosome
  chrStart = {}
  chrEnd = {}
  chrLength = {}
  totalChrLength = 0
  for chr in data.chr
    chrStart[chr] = d3.min(data.lod[chr].pos)
    chrEnd[chr] = d3.max(data.lod[chr].pos)
    chrLength[chr] = chrEnd[chr] - chrStart[chr]
    totalChrLength += chrLength[chr]

  chrPixelStart = {}
  chrPixelEnd = {}
  chrGap = 10
  cur = Math.round(chrGap/2) + pad.left
  for chr in data.chr
    chrPixelStart[chr] = cur
    chrPixelEnd[chr] = cur + Math.round((w[0]-chrGap*(data.chr.length))/totalChrLength*chrLength[chr])
    cur = chrPixelEnd[chr] + chrGap

  # vertical scales
  lodyScale = d3.scale.linear()
                .domain([0, maxLod])
                .range([pad.top+h-pad.inner, pad.top+pad.inner])
  effyScale = d3.scale.linear()
                .domain([minPhe, maxPhe])
                .range([pad.top+h-pad.inner, pad.top+pad.inner])

  # chromosome-specific horizontal scales
  lodxScale = {}
  chrColor = {}
  for chr in data.chr
    lodxScale[chr] = d3.scale.linear()
                        .domain([chrStart[chr], chrEnd[chr]])
                        .range([chrPixelStart[chr], chrPixelEnd[chr]])
    if chr % 2
      chrColor[chr] = lightGray
    else
      chrColor[chr] = darkGray

  average = (x) ->
    sum = 0
    for xv in x
      sum += xv
    sum / x.length

  # background rectangles for each chromosome, alternate color
  chrRect = lodpanel.append("g").attr("id", "chrRect").selectAll("empty")
     .data(data.chr)
     .enter()
     .append("rect")
     .attr("id", (d) -> "rect#{d}")
     .attr("x", (d) -> chrPixelStart[d] - chrGap/2)
     .attr("y", pad.top)
     .attr("width", (d) -> chrPixelEnd[d] - chrPixelStart[d]+chrGap)
     .attr("height", h)
     .attr("fill", (d) -> chrColor[d])
     .attr("stroke", "none")

  # lod curves by chr
  lodcurve = (chr) ->
      d3.svg.line()
        .x((d) -> lodxScale[chr](d))
        .y((d,i) -> lodyScale(data.lod[chr].lod[i]))

  curves = lodpanel.append("g").attr("id", "curves")
  dotsAtMarkers = lodpanel.append("g").attr("id", "dotsAtMarkers")

  markerClick = {}
  for chr in data.chr
    for m in data.markers[chr]
      markerClick[m] = 0

  # Using https://github.com/Caged/d3-tip
  #   [slightly modified in https://github.com/kbroman/d3-tip]
  martip = d3.svg.tip()
             .orient("right")
             .padding(3)
             .text((z) -> z)
             .attr("class", "d3-tip")
             .attr("id", "martip")

  for chr in data.chr
    curves.append("path")
          .datum(data.lod[chr].pos)
          .attr("d", lodcurve(chr))
          .attr("class", "thickline")
          .attr("stroke", darkBlue)
          .attr("fill", "none")
          .attr("stroke-width", 2)
          .style("pointer-events", "none")

    dotsAtMarkers.selectAll("empty")
          .data(data.markers[chr])
          .enter()
          .append("circle")
          .attr("class", "markerCircle")
          .attr("id", (d) -> "circle#{d}")
          .attr("cx", (d) -> lodxScale[chr](data.lod[chr].pos[data.markerindex[chr][d]]))
          .attr("cy", (d) -> lodyScale(data.lod[chr].lod[data.markerindex[chr][d]]))
          .attr("r", tinyRad)
          .attr("fill", pink)
          .attr("stroke", "none")

    dotsAtMarkers.selectAll("empty")
          .data(data.markers[chr])
          .enter()
          .append("circle")
          .attr("class", "markerCircle")
          .attr("id", (d) -> "circle#{d}")
          .attr("cx", (d) -> lodxScale[chr](data.lod[chr].pos[data.markerindex[chr][d]]))
          .attr("cy", (d) -> lodyScale(data.lod[chr].lod[data.markerindex[chr][d]]))
          .attr("r", bigCircRad)
          .attr("fill", purple)
          .attr("stroke", "none")
          .attr("opacity", 0)
          .on("mouseover", (d) ->
                 d3.select(this).attr("opacity", 1) unless markerClick[d]
                 martip.call(this,d))
          .on "mouseout", (d) ->
                 d3.select(this).attr("opacity", markerClick[d])
                 d3.selectAll("#martip").remove()
          

# load json file and call draw function
d3.json("data/spalding_onetime.json", draw)
