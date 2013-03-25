# SLOD and MLOD curves

load("Analysis/out_with_combined.RData")
load("Analysis/operm.RData")
source("my_plot_scanone.R")

# make figure
source("colors.R")
color[1:2] <- c("darkslateblue", "#DC143C")
bgcolor <- rgb(24, 24, 24, maxColorValue=255)

png(file="../Figs/slod_mlod.png", width=1100, height=650, pointsize=24)
par(fg="white",col="white",col.axis="white",col.lab="white",
    bg=bgcolor, mar=c(3.4, 3.1, 0.6, 0.6))

my.plot.scanone(out, lod=243, bandcol="gray80", col=color[2], ylab="", bg="gray70",
                yaxt="n", xlab="")
my.plot.scanone(out, lod=242, col=color[1], add=TRUE)
title(xlab="Chromosome", mgp=c(2, 0, 0), col.lab="Wheat")
title(ylab="LOD score", mgp=c(1.6, 0, 0), col.lab="Wheat")
axis(side=2, at=0:6, tick=FALSE, mgp=c(0, 0.3, 0), las=1)
thr <- apply(operm[,242:243], 2, quantile, 0.95)
u <- par("usr")
for(i in seq(along=thr)) {
  abline(h=thr[i], lty=2, col=color[i])
  text(u[2]-diff(u[1:2])*0.005, thr[i]-diff(u[3:4])*0.01, c("SLOD", "MLOD")[i],
       col=color[i], adj=c(1, 1), cex=0.8)
}


dev.off()

