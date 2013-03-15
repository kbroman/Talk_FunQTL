# pheno.coffee
#
# Interactive plot of Edgar Spalding's phenotype data 

# function that does all of the work
draw = (data) ->

  # colors
  darkBlue = "darkslateblue"
  lightGray = d3.rgb(230, 230, 230)
  darkGray = d3.rgb(200, 200, 200)
  pink = "hotpink"
  altpink = "#E9CFEC"
  purple = "#8C4374"
  darkred = "crimson"
  # bgcolor = "black"
  labelcolor = "white"
  titlecolor = "Wheat"
  maincolor = "Wheat"

  # size of data set
  nTimes = data.times.length
  nInd = data.pheno.length

  # min and max phenotype plus rearrange data
  phenoList = []
  minPhe = 999
  maxPhe = -999
  avePhe = []
  for i of data.pheno
    avePhe[i] = 0
    for j of data.pheno[i]
      phe = data.pheno[i][j]
      avePhe[i] += phe
      phenoList.push({row: i, col:j, value:phe})
      minPhe = phe if minPhe > phe
      maxPhe = phe if maxPhe < phe
    avePhe[i] /= nTimes

  # order individuals by average phenotype
  orderedInd = d3.range(nInd).sort (a,b) ->
    return -1 if avePhe[a] < avePhe[b]
    return +1 if avePhe[b] < avePhe[a]
    return 0
  
  # dimensions of panels
  pixelsPer = 3
  w = nTimes * pixelsPer
  h = [nInd * pixelsPer, 300]
  pad = {left:60, top:5, right:5, bottom: 40, inner: 5}

  # total size
  totalw = w + pad.left + pad.right
  totalh = h[0] + h[1] + pad.top*2 + pad.bottom*2

  # svg to contain upper and lower panels
  svg = d3.select("div#phenofig")
          .append("svg")
          .attr("height", totalh)
          .attr("width", totalw)

  # groups for the two panels, translated to have origin = (0,0)
  image = svg.append("g")
             .attr("transform", "translate(#{pad.left},#{pad.top})")
  curve = svg.append("g")
             .attr("transform", "translate(#{pad.left},#{pad.top*2+pad.bottom+h[0]})")
                  
  # background rectangle for upper panel
  image.append("rect")
       .attr("height", h[0])
       .attr("width", w)
       .attr("fill", "white")
       .attr("stroke", "black")
       .attr("stroke-width", 1)

  # background rectangle for lower panel
  curve.append("rect")
       .attr("height", h[1])
       .attr("width", w)
       .attr("fill", lightGray)
       .attr("stroke", "none")
       .attr("stroke-width", 1)

  # scales for upper panel
  xScaleImg = d3.scale.ordinal()
                .domain(d3.range(nTimes))
                .rangePoints([0, pixelsPer*nTimes], 0)
  yScaleImg = d3.scale.ordinal()
                .domain(d3.range(nInd))
                .rangePoints([0, pixelsPer*nInd], 0)
  zScaleImg = d3.scale.linear() # controls opacity
                .domain([minPhe, maxPhe])
                .range([0.001, 0.999])

  # scales for lower panel
  xScaleCurve = d3.scale.linear()
                  .domain([0, d3.max(data.times)])
                  .range([pad.inner, w-pad.inner])
  yScaleCurve = d3.scale.linear()
                  .domain([minPhe, maxPhe])
                  .range([h[1]-pad.inner, pad.inner])

  # the pixels in the upper panel
  imgPixels = image.append("g").attr("id", "imgPixels")
                 .selectAll("rect")
                 .data(phenoList)
                 .enter()
                 .append("rect")
                 .attr("class", "imgPixels")
                 .attr("x", (d) -> xScaleImg(d.col))
                 .attr("y", (d) -> yScaleImg(orderedInd[d.row]))
                 .attr("height", pixelsPer)
                 .attr("width", pixelsPer)
                 .attr("opacity", (d) -> zScaleImg(d.value))
                 .attr("fill", darkBlue)
                 .attr("stroke", "none")
                 .on("mouseover", (d) -> drawCurve(d.row))

  # function to draw curve for an individual
  drawCurve = (ind) ->
    return 0 if ind == curInd
    curInd = ind

    d3.select("g#phecurve").remove()

    # phenotype curve for an individual
    phecurve = (ind) ->
        d3.svg.line()
          .x((d) -> xScaleCurve(d))
          .y((d,di) -> yScaleCurve(data.pheno[ind][di]))

    # actually draw the curve
    thecurve = curve.append("g").attr("id", "phecurve")
    thecurve.append("path")
          .datum(data.times)
          .attr("d", phecurve(ind))
          .attr("stroke", darkBlue)
          .attr("fill", "none")
          .attr("stroke-width", "2")

    # text to indicate individual
    thecurve.append("text")
          .datum(ind)
          .text("line #{ind*1+1}") # *1 to turn it into a number
          .attr("x", w - 100)
          .attr("y", pad.inner*3)
          .attr("text-anchor", "start")
          .style("color", darkBlue)

  randomInd = Math.floor(Math.random()*nInd)
  drawCurve(randomInd)
  curInd = randomInd

# load json file and call draw function
d3.json("Data/spalding_pheno.json", draw)
