# Interactive lod curves and QTL effect plot for all time points
#
# This is awful code; I just barely know what I'm doing.

# function that does all of the work
draw = (data) ->

  d3.select("p#loading").remove()

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

  # calculate effects
  eff = []
  for i of data.ave1
    eff[i] = []
    for j of data.ave1[i]
      eff[i][j] = data.ave2[i][j] - data.ave1[i][j]

  # hash: pmarker -> chrindex
  pmarChr = {}
  for chr in data.chr
    for p of data.map[chr]
      pmarChr[p] = chr

  minLodShown = 1

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
  for p,pind in data.evenpmar
    i = data.evenpmarindex[p]
    for j of data.times
      chr = pmarChr[p]
      pos = data.map[chr][p]
      chrStart[chr] = pos if chrStart[chr] > pos
      chrEnd[chr] = pos if chrEnd[chr] < pos
      if data.lod[i][j] > minLodShown
        lodList.push({pmar: p,
        row: j*1, # the *1 is to deal with character strings
        effindex: pind,
        chr: pmarChr[p],
        xpos: pos,
        value: data.lod[i][j]})
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
                       .range([chrStartPixel[chr]+pixelPer/2, chrEndPixel[chr]*pixelPer/2])

  # dimensions
  totalpmar = data.evenpmar.length
  pad = {left:50, top:20, right:10, bottom: 30, inner: 2}
  imgw = pixelPer * (totalpmar + data.chr.length-1)
  imgh = pixelPer * data.times.length
  lodh = 225
  effh = (imgh - pad.top - pad.bottom)/2
  effw = 400
  h = [imgh, lodh, effh, effh]
  w = [imgw, imgw, effw, effw]
  left = [pad.left, pad.left,
          pad.left*2+w[0]+pad.right,
          pad.left*2+w[0]+pad.right]
  top =  [pad.top,
          pad.top*2+h[0]+pad.bottom,
          pad.top,
          pad.top*2 + h[2] + pad.bottom]

  totalh = h[0] + h[1] + (pad.top + pad.bottom)*2
  totalw = (w[0] + w[2]) + (pad.left + pad.right)*2
  console.log("width = #{totalw}, height = #{totalh}")

  # create svg
  svg = d3.select("div#lod_alltimes_fig")
          .append("svg")
          .attr("height", totalh)
          .attr("width", totalw)

  # panels
  panels = []
  panelnames = ["imagepanel", "lodpanel", "phepanel", "effpanel"]
  for i in [0...4]
    panels[i] = svg.append("g").attr("id", panelnames[i])
                   .attr("transform", "translate(#{left[i]}, #{top[i]})")

  # rectangles
  for i of panels
    panels[i].append("rect")
             .attr("height", h[i])
             .attr("width", w[i])
             .attr("fill",  "white")
             .attr("stroke", "black")
             .attr("stroke-width", 2)

  # maxima and minima
  minEff = 0
  maxEff = 0
  minPhe = data.ave1[0][0]
  maxPhe = data.ave1[0][0]
  for i of data.ave1
    for j of data.ave1[i]
      a1 = data.ave1[i][j]
      a2 = data.ave2[i][j]
      e  = eff[i][j]
      minPhe = a1 if minPhe > a1
      maxPhe = a1 if maxPhe < a1
      minPhe = a2 if minPhe > a2
      maxPhe = a2 if maxPhe < a2
      minEff = e  if minEff > e
      maxEff = e  if maxEff < e
  maxLod = -1
  minLod = 50
  for i of data.lod
    for j of data.lod[i]
      maxLod = data.lod[i][j] if maxLod < data.lod[i][j]
      minLod = data.lod[i][j] if minLod > data.lod[i][j]

  # center effect plot at 0
  maxEff = -minEff if -minEff > maxEff
  minEff = -maxEff if -maxEff < minEff


  # scales
  effYscale = d3.scale.linear()
                .domain([minEff, maxEff])
                .range([effh - pad.inner, pad.inner])
  pheYscale = d3.scale.linear()
                .domain([minPhe, maxPhe])
                .range([effh - pad.inner, pad.inner])

  lodYscale = d3.scale.linear()
                .domain([0, maxLod])
                .range([lodh - pad.inner, pad.inner])

  imgYscale = d3.scale.ordinal()
                .domain(d3.range(data.times.length))
                .rangePoints([imgh-pixelPer, 0], 0)


  imgZscale = d3.scale.linear()
                .domain([minLodShown, maxLod])
                .range([0, 1])
                .clamp(true)

  effXscale = d3.scale.linear()
                .domain([d3.min(data.times), d3.max(data.times)])
                .range([pad.inner, w[2]-pad.inner])

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

  # x-axis for effect and phenotype panels
  for i in [2..3]
    panels[i].selectAll("empty")
             .data([0..8])
             .enter()
             .append("line")
             .attr("y1", 0)
             .attr("y2", h[i])
             .attr("x1", (d) -> effXscale(d*60))
             .attr("x2", (d) -> effXscale(d*60))
             .attr("fill", "none")
             .attr("stroke", "darkGray")
             .attr("stroke-width", 1)
    panels[i].selectAll("empty")
             .data([0..8])
             .enter()
             .append("text")
             .text((d) -> d)
             .attr("y", h[i] + pad.bottom*0.5)
             .attr("x", (d) -> effXscale(d*60))
             .attr("fill", labelcolor)
             .attr("text-anchor", "middle")
    panels[i].append("text")
             .text("Time (hours)")
             .attr("x", w[i]/2)
             .attr("y", h[i]+pad.bottom)
             .attr("fill", titlecolor)
             .attr("text-anchor", "middle")


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
    panels[i].append("text")
             .text("Chromosome")
             .attr("fill", titlecolor)
             .attr("text-anchor", "middle")
             .attr("x", w[i]/2)
             .attr("y", h[i]+pad.bottom*0.9)

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

  ticks = [null, lodYscale.ticks(5),
          pheYscale.ticks(6), effYscale.ticks(6)]
  scale = [null, lodYscale, pheYscale, effYscale]
  ytitle = [null, "LOD score", "Ave phenotype", "QTL effect"]
  mult = [null, 0.6, 0.8, 0.7]
  for i in [1..3]
    panels[i].selectAll("empty")
             .data(ticks[i])
             .enter()
             .append("text")
             .text((d) -> nodig(d))
             .attr("x", -pad.left*0.1)
             .attr("y", (d) -> scale[i](d))
             .attr("fill", (d) ->
                return pink if d == 0 and i==3
                labelcolor)
             .attr("text-anchor", "end")
             .attr("dominant-baseline", "middle")
    panels[i].selectAll("empty")
             .data(ticks[i])
             .enter()
             .append("line")
             .attr("y1", (d) -> scale[i](d))
             .attr("y2", (d) -> scale[i](d))
             .attr("x1", 0)
             .attr("x2", w[i])
             .attr("fill", "none")
             .attr("stroke", (d) ->
                return pink if d == 0 and i==3
                "lightGray")
             .attr("stroke-width", 1)
    panels[i].append("text")
             .text(ytitle[i])
             .attr("x", -pad.left*mult[i])
             .attr("y", h[i]/2)
             .attr("text-anchor", "middle")
             .attr("dominant-baseline", "middle")
             .attr("transform", "rotate(270, #{-pad.left*mult[i]}, #{h[i]/2})")
             .attr("fill", titlecolor)


  # plot phenotype curves
  phePlot = (d) ->
    d

  # plot effect curve
  effCurve = (pmari) ->
     d3.svg.line()
       .x((t) -> effXscale(t))
       .y((t,i) -> effYscale(eff[pmari][i]))

  effPlot = (pmari) ->
    panels[3].append("path").attr("id", "effCurve")
             .datum(data.times)
             .attr("d", effCurve(pmari))
             .attr("stroke", darkBlue)
             .attr("fill", "none")
             .attr("stroke-width", "2")

  # plot lod curves
  lodPlot = (d) ->
    d

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
           .attr("fill", (d) ->
               if eff[d.effindex][d.row] < 0
                 return darkBlue
               darkRed)
           .attr("stroke",  (d) ->
               if eff[d.effindex][d.row] < 0
                 return darkBlue
               darkRed)
           .attr("stroke-width", 0)
           .attr("opacity", (d) -> imgZscale(d.value))
           .on("mouseover", (d) -> effPlot(d.effindex))
           .on("mouseout", ->
                 panels[3].selectAll("path#effCurve").remove())



# load json file and call draw function
d3.json("data/spalding_all_lod.json", draw)
