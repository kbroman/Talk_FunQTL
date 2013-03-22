##############################
# Figure with genotypes and selected phenotypes
##############################
source("colors.R")

color[1:2] <- c(rgb(102,203,254,maxColorValue=255),
           rgb(254,  0,128,maxColorValue=255))
bgcolor <- rgb(24, 24, 24, maxColorValue=255)


load("spal.RData")
source("my_geno_image.R")


png("../Figs/geno_pheno.png", width=1100, height=650, pointsize=24)
par(las=1,fg="white",col="white",col.axis="white",col.lab="white",
    bg=bgcolor, lwd=2, mfrow=c(1,2))

my.geno.image(spal, ylab="", main="")
title(main="Genotypes", col.main=color[7], mgp=c(3, 0, 0), line=2.5)

# plot of phenotype
phe <- spal$pheno
times <- colnames(phe)
times <- as.numeric(substr(times, 2, nchar(times)))/60
pheave <- colMeans(phe)
phesd <- apply(phe, 2, sd)
phemx <- max(phe)
phemn <- min(phe)
plot(times, phe[1,], xlab="Time (hours)", ylab="Tip angle", type="n",
     ylim=c(phemn, phemx), xaxs="i")
u <- par("usr")
rect(u[1], u[3], u[2], u[4], col="gray80")
abline(h=seq(-120, 0, by=20), v=c(2,4,6), col="white")
for(i in 1:nrow(phe))
  lines(times, phe[i,], col="gray50", lwd=1)
lines(times, pheave, col=color[4], lwd=2)

title(main="Phenotypes", col.main=color[7], mgp=c(3, 0, 0), line=2.5)


dev.off()
