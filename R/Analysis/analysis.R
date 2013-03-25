load("../spal.RData")
out <- scanone(spal, method="hk", phe=1:nphe(spal))
out[,244] <- rowMeans(out[,(1:nphe(spal)+2)])
out[,245] <- apply(out[,(1:nphe(spal)+2)], 1, max)
colnames(out)[244:245] <- c("mean", "max")
save(out, file="out_with_combined.RData")

load("operm.RData")
thr <- apply(operm, 2, quantile, 0.95)

#plot(out, lod=242:243, col=c("blue", "red"))
#abline(h=quantile(operm[,242], 0.95), col="blue", lty=2)
#abline(h=quantile(operm[,243], 0.95), col="red", lty=2)


# mean: QTL on chr 1 and 4, very close on chr 5
# max:  QTL on chr 1, 3, 4

# stepwiseQTL analysis
library(parallel)

# function to run stepwise analysis, followed by addqtl()
f <- function(i) {
  outsq <- stepwiseqtl(spal, phe=i, method="hk", additive.only=TRUE,
                            penalties=thr[i], verb=FALSE, keeplodprofile=TRUE)
  if(is.null(outsq) || length(outsq)==0)
    attr(outsq, "addqtl") <- scanone(spal, phe=i, method="hk")
  else 
    attr(outsq, "addqtl") <- addqtl(spal, phe=i, method="hk", qtl=outsq)
  outsq
}
  

# run stepwise
outsq <- mclapply(1:nphe(spal), f, mc.cores=24)
save(outsq, file="outsq.RData")

# run stepwise with more stringent threshold
thr <- rep(thr[length(thr)], nphe(spal))
outsq2 <- mclapply(1:nphe(spal), f, mc.cores=24)
save(outsq2, file="outsq2.RData")


######################################################################

# by-hand stepwise analysis with mean
meanqtl <- vector("list", 6)
mx <- max(out[,c(1,2,244)])
meanqtl[[1]] <- qtl <- makeqtl(spal, chr=mx[[1]], pos=mx[[2]], what="prob")
attr(meanqtl[[1]], "condlod") <- out[,c(1,2,244)]

# functions
faq <- function(i, theqtl)
  out <- addqtl(spal, phe=i, method="hk", qtl=theqtl)
getave <- function(oaq) {
  for(j in 2:length(oaq)) oaq[[1]][,3] <- oaq[[1]][,3] + oaq[[j]][,3]
  oaq[[1]][,3] <- oaq[[1]][,3]/nphe(spal)
  oaq[[1]]
}

# next steps
for(j in 2:length(meanqtl)) {
  cat(j, "\n")
  outaq <- mclapply(1:nphe(spal), faq, theqtl=meanqtl[[j-1]], mc.cores=24)
  outaqav <- getave(outaq)
  mx <- max(outaqav)
  meanqtl[[j]] <- addtoqtl(spal, qtl=meanqtl[[j-1]], chr=mx[[1]], pos=mx[[2]])
  attr(meanqtl[[j]], "condlod") <- outaqav
}


######################################################################

# by-hand stepwise analysis with mean
maxqtl <- vector("list", 6)
mx <- max(out[,c(1,2,245)])
maxqtl[[1]] <- qtl <- makeqtl(spal, chr=mx[[1]], pos=mx[[2]], what="prob")
attr(maxqtl[[1]], "condlod") <- out[,c(1,2,245)]

# function
getmx <- function(oaq) {
  mx <- matrix(ncol=length(oaq), nrow=nrow(oaq[[1]]))
  for(j in 1:length(oaq)) mx[,j] <- oaq[[j]][,3]
  oaq[[1]][,3] <- apply(mx, 1, max)
  oaq[[1]]
}

# next steps
for(j in 2:length(maxqtl)) {
  cat(j, "\n")
  outaq <- mclapply(1:nphe(spal), faq, theqtl=maxqtl[[j-1]], mc.cores=24)
  outaqmx <- getmx(outaq)
  mx <- max(outaqmx)
  maxqtl[[j]] <- addtoqtl(spal, qtl=maxqtl[[j-1]], chr=mx[[1]], pos=mx[[2]])
  attr(maxqtl[[j]], "condlod") <- outaqmx
}

######################################################################
# fitqtl, across times
ffq <- function(i, theqtl)
  fitqtl(spal, phe=i, method="hk", qtl=theqtl)[[1]][1,4]

for(j in seq(along=meanqtl)) {
  attr(meanqtl[[j]], "lod") <- mean(unlist(mclapply(1:nphe(spal), ffq, theqtl=meanqtl[[j]], mc.cores=24)))
  attr(meanqtl[[j]], "plod") <- attr(meanqtl[[j]], "lod") - j*thr[242]
}

for(j in seq(along=maxqtl)) {
  attr(maxqtl[[j]], "lod") <- max(unlist(mclapply(1:nphe(spal), ffq, theqtl=maxqtl[[j]], mc.cores=24)))
  attr(maxqtl[[j]], "plod") <- attr(maxqtl[[j]], "lod") - j*thr[243]
}

# for meanqtl[[3]], include profile LOD
# get profile LOD
prof <- vector("list", nphe(spal))
for(i in seq(along=prof))
  prof[[i]] <- attr(refineqtl(spal, phe=i, method="hk", qtl=meanqtl[[3]], verbose=FALSE), "lodprofile")
meanprof <- prof[[1]]
for(j in 1:3) {
  tmp <- matrix(ncol=length(prof), nrow=nrow(prof[[1]][[j]]))
  for(i in seq(along=prof))
    tmp[,i] <- prof[[i]][[j]][,3]
  meanprof[[j]][,3] <- rowMeans(tmp)
}
attr(meanqtl[[3]], "lodprofile") <- meanprof

# also, for meanqtl[[3]], get estimated effects
eff <- matrix(nrow=nphe(spal), ncol=length(meanqtl[[3]]$chr))
for(i in 1:nphe(spal)) {
  tmp <- fitqtl(spal, qtl=meanqtl[[3]], phe=i, dropone=FALSE, method="hk", get.ests=TRUE)
  eff[i,] <- tmp[[2]]$ests[-1]
}
attr(meanqtl[[3]], "effects") <- eff

save(meanqtl, file="meanqtl.RData")
save(maxqtl, file="maxqtl.RData")

