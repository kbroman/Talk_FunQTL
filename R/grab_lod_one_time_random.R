# Get LOD curve and data for a single time point
# and convert to JSON file for interactive graph


set.seed(69456948)
load("spal.RData")
thetime <- 32
spal$pheno[,thetime] <- sample(spal$pheno[,thetime])
out <- scanone(spal, phe=thetime, method="hk")

# marker index within lod curves
map <- pull.map(spal)
names(out)[3] <- "lod"
outspl <- split(out, out[,1])
mar <- map
for(i in seq(along=map)) {
  mar[[i]] <- match(names(map[[i]]), rownames(outspl[[i]]))-1
  names(mar[[i]]) <- names(map[[i]])
}
markers <- lapply(mar, names)

spali <- pull.geno(fill.geno(spal, err=0.002, map.function="kosambi"))
g <- pull.geno(spal)
spali[is.na(g) | spali != g] <- -spali[is.na(g) | spali != g]
spali <- as.list(as.data.frame(spali))
individuals <- 1:nind(spal)

# write data to JSON file
library(RJSONIO)
cat0 <- function(...) cat(..., sep="", file="../Data/onetime_random.json")
cat0a <- function(...) cat(..., sep="", file="../Data/onetime_random.json", append=TRUE)
cat0("{\n")
cat0a("\"random\": true,\n\n")
cat0a("\"phenotype\" : \"", paste("Tip angle at", (thetime-1)*2, "min"), "\",\n\n")
cat0a("\"chr\" :\n", toJSON(chrnames(spal)), ",\n\n")
cat0a("\"lod\" :\n", toJSON(lapply(split(out, out[,1]), function(a) as.list(a[,2:3])), digits=8), ",\n\n")
cat0a("\"markerindex\" :\n", toJSON(mar), ",\n\n")
cat0a("\"markers\" :\n", toJSON(markers), ",\n\n")
cat0a("\"phevals\" :\n", toJSON(spal$pheno[,32], digits=6), ",\n\n")
cat0a("\"geno\" :\n", toJSON(spali), ",\n\n")
cat0a("\"individuals\" :\n", toJSON(individuals), "\n\n")
cat0a("}\n")
