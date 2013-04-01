# Interactive multiple-QTL results for all time points

# function that does all of the work
drawStepwise = (data) ->
  d3.select("p#loading").remove()
  d3.select("p#loaded").style("opacity", 1)

  # no. pixels per rectangle in heatmap
  pixelPer = 1.5 # <- I wanted this to be an integer, but I couldn't fit the figure into a talk

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

  # hash: pmarker -> chrindex
  pmarChr = {}
  for chr in data.chr
    for p of data.map[chr]
      pmarChr[p] = chr

  minLodShown = 2.4

  # to contain the start and end positions
  chrStart = {}
  chrEnd = {}
  chrStartPixel = {}
  chrEndPixel = {}
  for chr in data.chr
    chrStart[chr] = 999
    chrEnd[chr] = -999

  # list version of LOD scores for heatmap
  lodList = []
  for i of data.lodprofile
    for j of data.times
      p = data.evenpmar[i]
      chr = pmarChr[p]
      pos = data.map[chr][p]
      chrStart[chr] = pos if chrStart[chr] > pos
      chrEnd[chr] = pos if chrEnd[chr] < pos
      if data.lodprofile[i][j] > minLodShown
        lodList.push({pmar: p,
        row: j*1, # the *1 is to deal with character strings
        chr: pmarChr[p],
        xpos: pos,
        value: data.lodprofile[i][j]})
  console.log("No. pixels = #{lodList.length}")

  # create X scale for image and LOD curves
  curPixel = 0
  imgXscale = {}
  lodXscale = {}
  for chr in data.chr
    chrStartPixel[chr] = curPixel
    chrEndPixel[chr] = curPixel + (chrEnd[chr] - chrStart[chr])*pixelPer
    curPixel = chrEndPixel[chr]+pixelPer*2
    imgXscale[chr] = d3.scale.linear()
                       .domain([chrStart[chr], chrEnd[chr]])
                       .range([chrStartPixel[chr], chrEndPixel[chr]])
    lodXscale[chr] = d3.scale.linear()
                       .domain([chrStart[chr], chrEnd[chr]])
                       .range([chrStartPixel[chr]+pixelPer/2, chrEndPixel[chr]+pixelPer/2])

  # dimensions
  totalpmar = data.evenpmar.length
  pad = {left:50, top:20, right:10, bottom: 30, inner: 2}
  imgw = pixelPer * (totalpmar + data.chr.length-1)
  imgh = pixelPer * data.times.length
  lodh = 225
  h = [imgh, lodh]
  w = [imgw, imgw]
  left = [pad.left, pad.left]
  top =  [pad.top,
          pad.top*2+h[0]+pad.bottom]

  totalh = h[0] + h[1] + (pad.top + pad.bottom)*2
  totalw = w[0] + (pad.left + pad.right)
  console.log("width = #{totalw}, height = #{totalh}")

  # create svg
  svg = d3.select("div#stepwise_fig")
          .append("svg")
          .attr("height", totalh)
          .attr("width", totalw)

  # panels
  panels = []
  panelnames = ["imagepanel", "lodpanel"]
  for i in [0...2]
    panels[i] = svg.append("g").attr("id", panelnames[i])
                   .attr("transform", "translate(#{left[i]}, #{top[i]})")

  # rectangles
  for i in [0..1]
    panels[i].append("rect")
             .attr("height", h[i])
             .attr("width", w[i])
             .attr("fill",  "white")
             .attr("stroke", "black")
             .attr("stroke-width", 2)

  maxLod = -1
  minLod = 50
  for i of data.lodprofile
    for j of data.lodprofile[i]
      maxLod = data.lodprofile[i][j] if maxLod < data.lodprofile[i][j]
      minLod = data.lodprofile[i][j] if minLod > data.lodprofile[i][j]

  # scales
  lodYscale = d3.scale.linear()
                .domain([0, maxLod])
                .range([lodh - pad.inner, pad.inner])

  imgYscale = d3.scale.ordinal()
                .domain(d3.range(data.times.length))
                .rangePoints([imgh-pixelPer, 0], 0)


  imgZscale = d3.scale.linear()
                .domain([0, maxLod])
                .range([0, 1])
                .clamp(true)

  # vertical lines at chromosome boundaries
  boundaries = []
  for chr in data.chr[1..]
    boundaries.push(chrStartPixel[chr])

  for i in [0..1]
    panels[i].append("g").attr("id", "chrBoundaryLines")
             .selectAll("empty")
             .data(boundaries)
             .enter()
             .append("line")
             .attr("y1", 0)
             .attr("y2", h[i])
             .attr("x1", (d) -> d-pixelPer*0.5)
             .attr("x2", (d) -> d-pixelPer*0.5)
             .attr("fill", "none")
             .attr("stroke", "darkGray")
             .attr("stroke-width", 1)

  # chromosome IDs on X axis
  for i in [0..1]
    panels[i].append("g").attr("id", "chrLabels")
             .selectAll("empty")
             .data(data.chr)
             .enter()
             .append("text")
             .attr("y", h[i]+pad.bottom*0.42)
             .attr("x", (d) -> (chrStartPixel[d]+chrEndPixel[d])/2)
             .text((d) -> d)
             .attr("fill", labelcolor)
             .attr("text-anchor", "middle")
  # "Chromosome" just at bottom
  panels[1].append("text")
           .text("Chromosome")
           .attr("fill", titlecolor)
           .attr("text-anchor", "middle")
           .attr("x", w[1]/2)
           .attr("y", h[1]+pad.bottom*0.9)

  # y-axis labels
  panels[0].append("g").attr("id", "imgYaxisLabels")
           .selectAll("empty")
           .data([0..8])
           .enter()
           .append("text")
           .text((d) -> d)
           .attr("x", -pad.left*0.1)
           .attr("y", (d) -> imgYscale(d*30))
           .attr("fill", labelcolor)
           .attr("text-anchor", "end")
           .attr("dominant-baseline", "middle")
  panels[0].append("g").attr("id", "imgYaxisGridlines")
           .selectAll("empty")
           .data([1..7])
           .enter()
           .append("line")
           .attr("y1", (d) -> imgYscale(d*30))
           .attr("y2", (d) -> imgYscale(d*30))
           .attr("x1", 0)
           .attr("x2", w[0])
           .attr("fill", "none")
           .attr("stroke", "lightGray")
           .attr("stroke-width", 1)
  panels[0].append("text")
           .text("Time (hours)")
           .attr("x", -pad.left*0.6)
           .attr("y", h[0]/2)
           .attr("text-anchor", "middle")
           .attr("dominant-baseline", "middle")
           .attr("transform", "rotate(270, #{-pad.left*0.6}, #{h[0]/2})")
           .attr("fill", titlecolor)

  ticks = lodYscale.ticks(5)
  mult = 0.6
  panels[1].selectAll("empty")
             .data(ticks)
             .enter()
             .append("text")
             .text((d) -> nodig(d))
             .attr("x", -pad.left*0.1)
             .attr("y", (d) -> lodYscale(d))
             .attr("fill", labelcolor)
             .attr("text-anchor", "end")
             .attr("dominant-baseline", "middle")
  panels[1].selectAll("empty")
             .data(ticks)
             .enter()
             .append("line")
             .attr("y1", (d) -> lodYscale(d))
             .attr("y2", (d) -> lodYscale(d))
             .attr("x1", 0)
             .attr("x2", w[0])
             .attr("fill", "none")
             .attr("stroke", "lightGray")
             .attr("stroke-width", 1)
  panels[1].append("text")
             .text("Profile LOD score")
             .attr("x", -pad.left*mult)
             .attr("y", h[1]/2)
             .attr("text-anchor", "middle")
             .attr("dominant-baseline", "middle")
             .attr("transform", "rotate(270, #{-pad.left*mult}, #{h[1]/2})")
             .attr("fill", titlecolor)

  # lod curve function
  lodCurve = (time, index) ->
    d3.svg.line()
      .x((d,i) -> lodXscale[data.detailedprof[time][index].chr](data.detailedprof[time][index].pos[i]))
      .y((d,i) -> lodYscale(data.detailedprof[time][index].lod[i]))

  addqtlCurve = (time, chr) ->
    d3.svg.line()
      .x((pmar) -> lodXscale[chr](data.map[chr][pmar]))
      .y((pmar) -> lodYscale(data.addqtllod[time][data.pmarindex[pmar]]))

  # plot LOD curves
  lodPlot = (time) ->
    # convert time into hour:min
    retime = Math.floor(time*2/60) + Math.round(time*2 % 60)/100
    retime = twodig(retime)
    retime = retime.replace(/\./, ":")
    panels[1].append("text").attr("id", "lodTitle")
             .text("time = #{retime}")
             .attr("x", w[1]/2)
             .attr("y", -pad.top*0.6)
             .attr("fill", maincolor)
             .attr("text-anchor", "middle")
             .attr("dominant-baseline", "middle")
    # LOD curves
    for qtl of data.detailedprof[time]
      panels[1].append("path").attr("class", "lodCurve")
               .datum(data.detailedprof[time][qtl].pos)
               .attr("d", lodCurve(time, qtl))
               .attr("stroke", colors(qtl))
               .attr("fill", "none")
               .attr("stroke-width", "2")

    # "add qtl" LOD curves
#    for chr in data.chr
#      panels[1].append("path").attr("class", "lodCurve")
#               .datum(data.allpmar[chr])
#               .attr("d", addqtlCurve(time, chr))
#               .attr("stroke", darkGray)
#               .attr("fill", "none")
#               .attr("stroke-width", "1")

  colors = d3.scale.category10()

  # plot points at QTL
  qtlPoints = (time) ->
    qtlchr = data.qtl[time].chr
    qtlpos = data.qtl[time].pos
    if qtlchr[0] is null
      return null
      
    panels[0].selectAll("empty")
             .data(qtlchr)
             .enter()
             .append("circle")
             .attr("class", "qtlpoint")
             .attr("fill", (d,i) -> colors(i))
             .attr("stroke", "black")
             .attr("stroke-width", "1")
             .attr("r", 3)
             .attr("cy", imgYscale(time))
             .attr("cx", (d,i) -> imgXscale[d](qtlpos[i])+pixelPer/2)
             .style("pointer-events", "none")
    panels[1].selectAll("empty")
             .data(qtlchr)
             .enter()
             .append("circle")
             .attr("class", "qtlpoint")
             .attr("fill", (d,i) -> colors(i))
             .attr("stroke", "black")
             .attr("stroke-width", "1")
             .attr("r", 3)
             .attr("cy", 5)
             .attr("cx", (d,i) -> lodXscale[d](qtlpos[i]))
             .style("pointer-events", "none")

  # image plot
  panels[0].append("g").attr("id", "imagerect")
           .selectAll("empty")
           .data(lodList)
           .enter()
           .append("rect")
           .attr("x", (d) -> imgXscale[d.chr](d.xpos))
           .attr("width", pixelPer)
           .attr("y", (d) -> imgYscale(d.row))
           .attr("height", pixelPer)
           .attr("fill", darkBlue)
           .attr("stroke",  darkBlue)
           .attr("stroke-width", 0)
           .attr("opacity", (d) -> imgZscale(d.value))
           .on "mouseover", (d) ->
               qtlPoints(d.row)
               lodPlot(d.row)
           .on "mouseout", ->
                 panels[0].selectAll("circle.qtlpoint").remove()
                 panels[1].selectAll("circle.qtlpoint").remove()
                 panels[1].selectAll("path.lodCurve").remove()
                 panels[1].select("text#lodTitle").remove()
