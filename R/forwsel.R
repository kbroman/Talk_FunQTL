# figures illustrating forward selection

load("spal.RData")
load("Analysis/operm.RData")
source("my_plot_scanone.R")

# make figure
source("colors.R")
color[1:2] <- c("darkslateblue", "#DC143C")
bgcolor <- rgb(24, 24, 24, maxColorValue=255)

time <- 32
thr <- quantile(operm[,time], 0.95)

for(k in 1:3) {

  png(file=paste0("../Figs/forwsel", k, ".png"), width=1100, height=650, pointsize=24)
  par(fg="white",col="white",col.axis="white",col.lab="white",
      bg=bgcolor, mar=c(3.4, 3.1, 2.1, 0.6))

  if(k==1) {
    out <- scanone(spal, method="hk", phe=time)
    mx <- max(out)
    qtl <- makeqtl(spal, chr=mx[[1]], pos=mx[[2]], what="prob")
    ymx <- max(out[,3])
  } else {
    out <- addqtl(spal, qtl=qtl, method="hk", phe=time)
    mx <- max(out)
    qtl <- addtoqtl(spal, qtl=qtl, chr=mx[[1]], pos=mx[[2]])
  }

  my.plot.scanone(out,  bandcol="gray70", col=color[1], ylab="", bg="gray80",
                  yaxt="n", xlab="", ylim=c(0, ymx))
  
  abline(h=thr, col=color[1], lty=2)

  if(k>1) {
    my.plot.scanone(prev, col="gray50", add=TRUE)
    my.plot.scanone(out,  col=color[1], add=TRUE)
  }
  
  title(xlab="Chromosome", mgp=c(2, 0, 0), col.lab="Wheat")
  title(ylab="LOD score", mgp=c(1.6, 0, 0), col.lab="Wheat")
  title(main=paste("Step", k), col.main="Wheat", line=1)
  axis(side=2, at=0:6, tick=FALSE, mgp=c(0, 0.3, 0), las=1)

  dev.off()

  prev <- out
}


