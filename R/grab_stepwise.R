# Grab profile LOD curves for all time points 
# and convert to JSON file for interactive graph

# load R/qtl package
library(qtl)

# load phenotype and genotype data
load("spal.RData")

# load scanone results, each time point considered individually
ifiles <- c("Analysis/outsq.RData", "Analysis/outsq2.RData")
ofiles <- c("../Data/stepwise.json", "../Data/stepwise2.json")
for(ifile in 1:2) {
load(ifiles[ifile])
if(ifile == 2) outsq <- outsq2

# times (in minutes)
times <- as.numeric(substr(phenames(spal), 2, nchar(phenames(spal))))

# genetic map at which LOD scores were calculated
map <- lapply(spal$geno, function(a) attr(a$prob, "map"))
for(i in seq(along=map)) {
  nam <- names(map[[i]])
  g <- grep("^loc[0-9]*$", nam)
  nam[g] <- paste0("c", i, ".", nam[g])
  names(map[[i]]) <- nam
}

# pseudomarker indices, for even spacing (every cM)
evenpmarindex <- lapply(map, function(a) a[match(seq(0, max(a), by=1), a)])
evenpmar <- unlist(lapply(evenpmarindex, names))
names(evenpmar) <- NULL

# all pseudomarkers
allpmar <- lapply(map, names)
pmarindex <- (1:length(unlist(allpmar)))-1
names(pmarindex) <- unlist(allpmar)

evenpmarindex <- pmarindex[evenpmar]

# matrix with LOD profiles
lod <- matrix(ncol=length(times), nrow=length(pmarindex))
aq <- attr(outsq[[1]], "addqtl")
chr <- aq[,1]
pos <- aq[,2]
rownames(lod) <- rownames(aq)
for(i in seq(along=times)) {
  lod[,i] <- attr(outsq[[i]], "addqtl")[,3]
  lp <- attr(outsq[[i]], "lodprofile")
  if(length(lp) > 0) {
    for(j in seq(along=lp)) {
      m <- rownames(lp[[j]])
      lod[m ,i] <- apply(cbind(lod[m,i], lp[[j]][,3]), 1, max, na.rm=TRUE)
    }
  }
}
lod <- lod[evenpmarindex,]
dimnames(lod) <- NULL

qtl <- vector("list", length(times))
for(i in seq(along=qtl)) {
  if(length(outsq[[i]]) > 0)
    qtl[[i]] <- list(chr=outsq[[i]]$chr, pos=outsq[[i]]$pos)
  else
    qtl[[i]] <- list(chr=NULL, pos=NULL)
}

detailedprof <- vector("list", length(times))
for(i in seq(along=qtl)) {
  lp <- attr(outsq[[i]], "lodprofile")
  detailedprof[[i]] <- vector("list", length(lp))
  for(j in seq(along=lp))
    detailedprof[[i]][[j]] <- list(chr=as.character(lp[[j]][1,1]),
                                   pos=lp[[j]][,2],
                                   lod=lp[[j]][,3])
}


addqtllod <- vector("list", length(times))
for(i in seq(along=qtl)) {
  addqtllod[[i]] <- attr(outsq[[i]], "addqtl")[,3]
  names(addqtllod[[i]]) <- NULL
}



# write data to JSON file
library(RJSONIO)
cat0 <- function(..., file="blah") cat(..., sep="", file=file)
cat0a <- function(..., file="blah") cat(..., sep="", file=file, append=TRUE)
cat0("{\n", file=ofiles[ifile])
cat0a("\"chr\" :\n", toJSON(chrnames(spal)), ",\n\n", file=ofiles[ifile])
cat0a("\"map\" :\n", toJSON(map, digits=10), ",\n\n", file=ofiles[ifile])
cat0a("\"allpmar\" :\n", toJSON(allpmar), ",\n\n", file=ofiles[ifile])
cat0a("\"evenpmar\" :\n", toJSON(evenpmar), ",\n\n", file=ofiles[ifile])
cat0a("\"pmarindex\" :\n", toJSON(pmarindex), ",\n\n", file=ofiles[ifile])
cat0a("\"times\" :\n", toJSON(times), ",\n\n", file=ofiles[ifile])
cat0a("\"lodprofile\" :\n", toJSON(lod), ",\n\n", file=ofiles[ifile])
cat0a("\"qtl\" :\n", toJSON(qtl, asIs=TRUE), ",\n\n", file=ofiles[ifile])
cat0a("\"detailedprof\" :\n", toJSON(detailedprof), ",\n\n", file=ofiles[ifile])
cat0a("\"addqtllod\" :\n", toJSON(addqtllod), "\n\n", file=ofiles[ifile])
cat0a("}\n", file=ofiles[ifile])
}
