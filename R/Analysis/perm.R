# run permutations for each time point individually
#
# keep track of maximum LOD for each time point,
# maximum mean LOD score across time points, and overall maximum
set.seed(94492360+SUB)

load("spal.RData")

n.perm <- 625
tmp <- spal
n.ind <- nind(spal)
n.phe <- nphe(spal)

operm <- matrix(ncol=n.phe+2, nrow=n.perm)
colnames(operm) <- c(phenames(spal), c("mean", "max"))

for(i in 1:n.perm) {
  cat(i, "\n")
  tmp$pheno <- spal$pheno[sample(n.ind),]
  out <- scanone(tmp, phe=1:241, method="hk")
  mx <- apply(out[,-(1:2)], 2, max)
  operm[i,] <- c(mx, max(rowMeans(out[,-(1:2)])), max(mx))
}

save(operm, file="opermSUB.RData")
