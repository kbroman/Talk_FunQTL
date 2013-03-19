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

  # Circle radius in plotPXG
  peakRad = 2
  bigRad = 5

  # dimensions of SVG
  w = [800, 200]
  h = 500
  pad = {left:60, top:40, right:10, bottom: 60, inner: 5}
  totalw = w[0]+w[1]+pad.left*2+pad.right*2
  totalh = h + pad.top + pad.bottom

  left = [pad.left, 2*pad.left + w[0] + pad.right]

  # max LOD and min/max phenotype
  minPhe = d3.min(data.phevals)
  maxPhe = d3.max(data.phevals)
  maxLod = 0
  maxLod_marker = ""
  maxLodByChr = {}
  maxLodByChr_marker = {}
  tmp = 0
  for chr in data.chr
    maxLodByChr[chr] = 0
    maxLodByChr_marker[chr] = ""
    for lod in data.lod[chr].lod
      maxLod = lod if maxLod < lod  # overall maximum LOD
    for m of data.markerindex[chr]
      lod = data.lod[chr].lod[data.markerindex[chr][m]]
      if lod > maxLodByChr[chr]
        maxLodByChr[chr] = lod  # max LOD by chromosome, among marker positions
        maxLodByChr_marker[chr] = m
      if lod > tmp
        tmp = lod
        maxLod_marker = m  # marker with maximum LOD

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
  effxScale = d3.scale.ordinal()
                 .domain([1,2])
                 .rangePoints([left[1], left[1]+w[1]], 1)

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

  # chromosome for each marker
  markerchr = {}
  for chr in data.chr
    for m in data.markers[chr]
      markerchr[m] = chr

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

  # axes
  lodaxes = lodpanel.append("g").attr("id", "lodaxes")
  lodticks = lodyScale.ticks(5)
  lodaxes.append("g").attr("id", "lod_yaxis_lines")
      .selectAll("empty")
      .data(lodticks)
      .enter()
      .append("line")
      .attr("x1", pad.left)
      .attr("x2", pad.left+w[0])
      .attr("y1", (d) -> lodyScale(d))
      .attr("y2", (d) -> lodyScale(d))
      .attr("stroke", labelcolor)
      .attr("stroke-width", 1)
  lodaxes.append("g").attr("id", "lod_yaxis_labels")
      .selectAll("empty")
      .data(lodticks)
      .enter()
      .append("text")
      .attr("x", pad.left*0.7)
      .attr("y", (d) -> lodyScale(d))
      .text((d) -> nodig(d))
      .attr("fill", labelcolor)
      .attr("dominant-baseline", "middle")
  xloc = pad.left*0.4
  yloc = pad.top + h/2
  lodaxes.append("text").attr("id", "lod_yaxis_title")
      .attr("x", xloc)
      .attr("y", yloc)
      .text("LOD score")
      .attr("transform", "rotate(270, #{xloc}, #{yloc})")
      .attr("fill", titlecolor)
      .attr("text-anchor", "middle")
  lodaxes.append("g").attr("id", "lod_xaxis_labels")
      .selectAll("empty")
      .data(data.chr)
      .enter()
      .append("text")
      .text((d) -> d)
      .attr("x", (d) -> (chrPixelStart[d]+chrPixelEnd[d])/2)
      .attr("y", pad.top+h+pad.bottom*0.15)
      .attr("fill", labelcolor)
      .attr("text-anchor", "middle")
      .attr("dominant-baseline", "hanging")
  lodaxes.append("text").attr("id", "lod_xaxis_title")
      .text("Chromosome")
      .attr("x", pad.left + w[0]/2)
      .attr("y", pad.top+h+pad.bottom*0.5)
      .attr("text-anchor", "middle")
      .attr("fill", titlecolor)
      .attr("dominant-baseline", "hanging")
  effaxes = effpanel.append("g").attr("id", "effaxes")
  effticks = effyScale.ticks(7)
  effaxes.append("g").attr("id", "eff_xaxis_lines")
      .selectAll("empty")
      .data([1,2])
      .enter()
      .append("line")
      .attr("x1", (d) -> effxScale(d))
      .attr("x2", (d) -> effxScale(d))
      .attr("y1", pad.top)
      .attr("y2", pad.top+h)
      .attr("stroke", darkGray)
      .attr("stroke-width", 1)
  effaxes.append("g").attr("id", "eff_xaxis_labels")
      .selectAll("empty")
      .data([1,2])
      .enter()
      .append("text")
      .attr("x", (d) -> effxScale(d))
      .attr("y", pad.top+h+pad.bottom*0.15)
      .text((d) -> ["AA", "BB"][d-1])
      .attr("fill", labelcolor)
      .attr("text-anchor", "middle")
      .attr("dominant-baseline", "hanging")
  effaxes.append("text").attr("id", "lod_xaxis_title")
      .text("Genotype")
      .attr("x", left[1] + w[1]/2)
      .attr("y", pad.top+h+pad.bottom*0.5)
      .attr("text-anchor", "middle")
      .attr("fill", titlecolor)
      .attr("dominant-baseline", "hanging")
  effaxes.append("g").attr("id", "eff_yaxis_lines")
      .selectAll("empty")
      .data(effticks)
      .enter()
      .append("line")
      .attr("x1", left[1])
      .attr("x2", left[1]+w[1])
      .attr("y1", (d) -> effyScale(d))
      .attr("y2", (d) -> effyScale(d))
      .attr("stroke", labelcolor)
      .attr("stroke-width", 1)
  effaxes.append("g").attr("id", "eff_yaxis_labels")
      .selectAll("empty")
      .data(effticks)
      .enter()
      .append("text")
      .attr("x", left[1]-pad.left*0.1)
      .attr("y", (d) -> effyScale(d))
      .text((d) -> nodig(d))
      .attr("fill", labelcolor)
      .attr("text-anchor", "end")
      .attr("dominant-baseline", "middle")
  xloc = left[1]-pad.left*0.7
  yloc = pad.top + h/2
  effaxes.append("text").attr("id", "eff_yaxis_title")
      .attr("x", xloc)
      .attr("y", yloc)
      .text("Tip angle at 62 min")
      .attr("transform", "rotate(270, #{xloc}, #{yloc})")
      .attr("fill", titlecolor)
      .attr("text-anchor", "middle")

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
  lastMarker = maxLod_marker
  markerClick[maxLod_marker] = 1

  # Using https://github.com/Caged/d3-tip
  #   [slightly modified in https://github.com/kbroman/d3-tip]
  martip = d3.svg.tip()
             .orient("right")
             .padding(3)
             .text((z) -> z)
             .attr("class", "d3-tip")
             .attr("id", "martip")
  indtip = d3.svg.tip()
             .orient("right")
             .padding(3)
             .text((d,i) -> data.individuals[i])
             .attr("class", "d3-tip")
             .attr("id", "indtip")
  efftip = d3.svg.tip()
             .orient("right")
             .padding(3)
             .text((d) -> onedig(d))
             .attr("class", "d3-tip")
             .attr("id", "efftip")

  effpanel.append("text").attr("id", "pxgtitle_marker")
    .attr("x", left[1]+w[1]/2)
    .attr("y", pad.top*0.02)
    .text("")
    .attr("fill", titlecolor)
    .attr("text-anchor", "middle")
    .attr("dominant-baseline", "hanging")
  effpanel.append("text").attr("id", "pxgtitle_position")
    .attr("x", left[1]+w[1]/2)
    .attr("y", pad.top*0.52)
    .text("")
    .attr("fill", labelcolor)
    .attr("text-anchor", "middle")
    .attr("dominant-baseline", "hanging")

  # functions to plot phenotype vs genotype
  plotPXG = (marker) ->
      means = [0, 0]
      n = [0, 0]
      # calculate group averages
      for i of data.geno[marker]
         g = Math.abs(data.geno[marker][i])
         means[g-1] += data.phevals[i]
         n[g-1]++
      for i of means
        means[i] /= n[i]

      effpanel.append("g").attr("id", "means")
          .selectAll("empty")
          .data(means)
          .enter()
          .append("line")
          .attr("class", "plotPXG")
          .attr("x1", (d,i) -> effxScale(i+1) - jitterAmount*4)
          .attr("x2", (d,i) -> effxScale(i+1) + jitterAmount*4)
          .attr("y1", (d) -> effyScale(d))
          .attr("y2", (d) -> effyScale(d))
          .attr("stroke", darkBlue)
          .attr("stroke-width", 4)
          .attr("fill", "none")
          .on("mouseover", efftip)
          .on("mouseout", -> d3.selectAll("#efftip").remove())

      effpanel.append("g").attr("id", "plotPXG")
          .selectAll("empty")
          .data(data.phevals)
          .enter()
          .append("circle")
          .attr("class", "plotPXG")
          .attr("cx", (d,i) ->
              g = Math.abs(data.geno[marker][i])
              effxScale(g)+jitter[i])
          .attr("cy", (d) -> effyScale(d))
          .attr("r", peakRad)
          .attr("fill", (d,i) ->
              return pink if data.geno[marker][i] < 0
              darkGray)
          .attr("stroke", (d,i) ->
               return purple if data.geno[marker][i] < 0
               "black")
          .attr("stroke-width", (d,i) ->
               return "2" if data.geno[marker][i] < 0
               "1")
          .on "mouseover", (d,i) ->
               d3.select(this).attr("r", bigRad)
               indtip.call(this, d, i)
          .on "mouseout", ->
               d3.selectAll("#indtip").remove()
               d3.select(this).attr("r", peakRad)

  revPXG = (marker) ->
      # calculate group averages
      means = [0,0]
      n = [0,0]
      # calculate group averages
      for i of data.geno[marker]
         g = Math.abs(data.geno[marker][i])
         means[g-1] += data.phevals[i]
         n[g-1]++
      for i of means
        means[i] /= n[i]

      effpanel.selectAll("line.plotPXG")
          .data(means)
          .transition().duration(1000)
          .attr("y1", (d) -> effyScale(d))
          .attr("y2", (d) -> effyScale(d))

      svg.selectAll("circle.plotPXG")
         .data(data.phevals)
         .transition().duration(1000)
         .attr("cx", (d,i) ->
              g = Math.abs(data.geno[marker][i])
              effxScale(g)+jitter[i])
         .attr("fill", (d,i) ->
              return pink if data.geno[marker][i] < 0
              darkGray)
         .attr("stroke", (d,i) ->
               return purple if data.geno[marker][i] < 0
               "black")
         .attr("stroke-width", (d,i) ->
               return "2" if data.geno[marker][i] < 0
               "1")

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
          .attr("id", (d) -> "circ#{markerchr[d]}_#{data.markerindex[markerchr[d]][d]}")
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
          .on "click", (d) ->
              chr = markerchr[d]
              index = data.markerindex[chr][d]
              pos = data.lod[chr].pos[index]
              title = "(chr #{chr}, #{onedig(pos)} cM)"
              d3.selectAll("text#pxgtitle_marker").text(d)
              d3.selectAll("text#pxgtitle_position").text(title)
              markerClick[lastMarker] = 0
              lastchr = markerchr[lastMarker]
              lastindex = data.markerindex[lastchr][lastMarker]
              d3.select("circle#circ#{lastchr}_#{lastindex}").attr("opacity", 0).attr("fill",purple).attr("stroke","none")
              revPXG d
              lastMarker = d
              markerClick[d] = 1
              d3.select(this).attr("opacity", 1).attr("fill",altpink).attr("stroke",purple)

  chr = markerchr[maxLod_marker]
  index = data.markerindex[chr][maxLod_marker]
  pos = data.lod[chr].pos[index]
  title = "(chr #{chr}, #{onedig(pos)} cM)"
  d3.selectAll("text#pxgtitle_marker").text(maxLod_marker)
  d3.selectAll("text#pxgtitle_position").text(title)
  plotPXG(maxLod_marker)
  d3.select("circle#circ#{chr}_#{index}").attr("opacity", 1).attr("fill",altpink).attr("stroke",purple)

# load json file and call draw function
d3.json("data/onetime.json", draw)
