# prep_rep1_data.R
#
# load genotype & phenotype data
# Perform single-QTL analysis using Haley-Knott regression

library(qtl)

spal <- read.cross("csv", "../Rawdata", "rep1_rev.csv", genotypes=c("A","B"), na.strings="*")
spal <- convert2riself(spal)
spal <- jittermap(spal)

nxo <- countXO(spal)
spal <- spal[,nxo > 0] # omit parental lines

spal <- calc.genoprob(spal, map.function="kosambi", step=1)
out <- scanone(spal, method="hk", phe=1:241)

save(spal, file="spal.RData")
save(out, file="out.RData")
