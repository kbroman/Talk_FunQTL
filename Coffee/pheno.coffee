# pheno.coffee
#
# Interactive plot of Edgar Spalding's phenotype data 

# function that does all of the work
draw = (data) ->

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
  
  for i in [0..5]
    console.log(i, avePhe[i], orderedInd[i],  avePhe[orderedInd[i]])

  # dimensions of panels
  pixelsPer = 3
  w = nTimes * pixelsPer
  h = [nInd * pixelsPer, 300]
  pad = {left:60, top:40, right:40, bottom: 40, inner: 10}

  # total size
  totalw = w + pad.left + pad.right
  totalh = h[0] + h[1] + pad.top*2 + pad.bottom*2

  svg = d3.select("div#phenofig")
          .append("svg")
          .attr("height", totalh)
          .attr("width", totalw)

  image = svg.append("g")
             .attr("transform", "translate(#{pad.left},#{pad.top})")
  curve = svg.append("g")
             .attr("transform", "translate(#{pad.left},#{pad.top*2+pad.bottom+h[0]})")
                         
  image.append("rect")
       .attr("height", h[0])
       .attr("width", w)
       .attr("fill", "white")
       .attr("stroke", "black")
       .attr("stroke-width", 1)

  curve.append("rect")
       .attr("height", h[1])
       .attr("width", w)
       .attr("fill", "none")
       .attr("stroke", "white")
       .attr("stroke-width", 1)

  xScaleImg = d3.scale.ordinal()
                .domain(d3.range(nTimes))
                .rangePoints([0, pixelsPer*nTimes], 0)
  yScaleImg = d3.scale.ordinal()
                .domain(d3.range(nInd))
                .rangePoints([0, pixelsPer*nInd], 0)
  zScaleImg = d3.scale.linear() # controls opacity
                .domain([minPhe, maxPhe])
                .range([0.001, 0.999])

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
                 .attr("fill", "darkslateblue")
                 .attr("stroke", "none")


  drawCurve = (ind) ->
    


# load json file and call draw function
d3.json("Data/spalding_pheno.json", draw)
