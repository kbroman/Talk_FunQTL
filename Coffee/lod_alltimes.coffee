# Interactive lod curves and QTL effect plot for all time points
#
# This is awful code; I just barely know what I'm doing.

# function that does all of the work
draw = (data) ->

  d3.select("p#loading").remove()

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
  pmarkChr = {}
  for chr in data.chr
    for pmark of data.map[chr]
      pmarkChr[pmark] = chr

  minLodShown = 0.01dm

  # list version of LOD scores for heatmap
  lodList = []
  for p,pind in data.evenpmar
    i = data.evenpmarindex[p]
    for j of data.times
      if data.lod[i][j] > minLodShown
        lodList.push({pmar: p,
        row: j*1,
        col: pind*1 + pmarkChr[p]*1 - 1,
        value: data.lod[i][j]})
  console.log("No. pixels = #{lodList.length}")
      
  # dimensions
  pixelPer = 2
  totalpmar = data.evenpmar.length
  pad = {left:60, top:25, right:25, bottom: 60, inner: 2}
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
                .rangePoints([0, imgh-pixelPer], 0)

  imgXscale = d3.scale.ordinal()
                .domain(d3.range(imgw/pixelPer))
                .rangePoints([0, imgw-pixelPer], 0)

  imgZscale = d3.scale.linear()
                .domain([minLodShown, maxLod])
                .range([0, 1])
                .clamp(true)

  panels[0].append("g").attr("id", "imagerect")
           .selectAll("empty")
           .data(lodList)
           .enter()
           .append("rect")
           .attr("x", (d) -> imgXscale(d.col))
           .attr("width", pixelPer)
           .attr("y", (d) -> imgYscale(d.row))
           .attr("height", pixelPer)
           .attr("fill", darkBlue)
           .attr("stroke", darkBlue)
           .attr("stroke-width", 0.5)
           .attr("opacity", (d) -> imgZscale(d.value))


# load json file and call draw function
d3.json("data/spalding_all_lod.json", draw)
