# SLOD and MLOD curves

source("my_plot_scanone.R")
load("Analysis/meanqtl.RData")
load("spal.RData")
load("Analysis/operm.RData")
thr <- apply(operm, 2, quantile, 0.95)

# make figure
source("colors.R")
pink <- color[3]
color[1:3] <- c("darkslateblue", "#DC143C", "darkgreen")
bgcolor <- rgb(24, 24, 24, maxColorValue=255)

png("../Figs/slod_multiqtl.png", width=900, height=750, pointsize=24)
par(fg="white",col="white",col.axis="white",col.lab="white",
    bg=bgcolor, mar=c(3.4, 3.1, 2.1, 0.6), mfrow=c(2,1))

# profile LOD curves
clod <- attr(meanqtl[[3]], "condlod")
prof <- attr(meanqtl[[3]], "lodprofile")
clodalt <- vector("list", length(prof))
ymx <- max(clod[,3])
for(i in seq(along=prof))
  ymx <- max(c(ymx, prof[[i]][,3]))
for(i in seq(along=prof)) {
  chr <- as.character(prof[[i]][1,1])
  clod[clod[,1]==chr,3] <- NA
  clodalt[[i]] <- clod
  clodalt[[i]][,3] <- NA
  clodalt[[i]][clod[,1]==chr,3] <- prof[[i]][,3]
}

my.plot.scanone(clod,  bandcol="gray70", col="gray50", ylab="", bg="gray80",
                yaxt="n", xlab="", ylim=c(0, ymx))
abline(h=thr[242], col=color[1], lty=2)

for(i in seq(along=clodalt))
  my.plot.scanone(clodalt[[i]], add=TRUE, col=color[i])


title(xlab="Chromosome", mgp=c(2, 0, 0), col.lab="Wheat")
title(ylab="Profile LOD score", mgp=c(1.6, 0, 0), col.lab="Wheat")
axis(side=2, at=0:6, tick=FALSE, mgp=c(0, 0.3, 0), las=1)

xpos <- xaxisloc.scanone(clod, meanqtl[[3]]$chr, meanqtl[[3]]$pos)
points(xpos, rep(0, length(xpos)), pch=21, lwd=2, col="black",
       bg=color[1:3])


eff <- attr(meanqtl[[3]], "effects")

times <- seq(0, 8, len=nphe(spal))
plot(times, eff[,1], ylim=c(-max(abs(eff)), max(abs(eff))),
     xaxt="n", yaxt="n", xlab="", ylab="", type="n", xaxs="i")
u <- par("usr")
rect(u[1], u[3], u[2], u[4], col="gray80")
xtick <- seq(-4, 4, by=2)[-3]
axis(side=2, at=xtick, tick=FALSE, mgp=c(0, 0.3, 0), las=1)
abline(h=xtick, col="white")
axis(side=2, at=0, tick=FALSE, mgp=c(0, 0.3, 0), las=1, col.axis=pink)
abline(h=0, col=pink)
ytick <- 0:8
axis(side=1, at=ytick, tick=FALSE, mgp=c(0, 0.3, 0), las=1)
abline(v=ytick, col="white")
title(xlab="Time (hours)", mgp=c(2, 0, 0), col.lab="Wheat")
title(ylab="QTL effect", mgp=c(1.6, 0, 0), col.lab="Wheat")
for(i in 1:ncol(eff))
  lines(times, eff[,i], col=color[i], lwd=2)

dev.off()

