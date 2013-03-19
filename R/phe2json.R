# save the Spalding phenotypes to json format
load("spal.RData")
phenam <- phenames(spal)
times <- as.numeric(substr(phenam, 2, nchar(phenam))) # time in minutes (480 min = 8 hrs)

pheno <- as.matrix(spal$pheno)
dimnames(pheno) <- NULL

library(RJSONIO)

cat0 <- function(file, ...) cat(..., sep="", file=file)
cat0a <- function(file, ...) cat(..., sep="", file=file, append=TRUE)

file <- "../Data/pheno.json"
cat0(file, "{\n")
cat0a(file, "\"times\" : \n", toJSON(times), ",\n\n")
cat0a(file, "\"pheno\" : \n", toJSON(pheno), "\n\n")
cat0a(file, "}\n")

