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

n.step <- 3
out <- vector("list", n.step)
for(k in 1:n.step) {

  png(file=paste0("../Figs/forwsel", k, ".png"), width=1100, height=650, pointsize=24)
  par(fg="white",col="white",col.axis="white",col.lab="white",
      bg=bgcolor, mar=c(3.4, 3.1, 2.1, 0.6))

  if(k==1) {
    out[[k]] <- scanone(spal, method="hk", phe=time)
    mx <- max(out[[k]])
    qtl <- makeqtl(spal, chr=mx[[1]], pos=mx[[2]], what="prob")
    ymx <- 6 #max(out[[k]][,3])
  } else {
    out[[k]] <- addqtl(spal, qtl=qtl, method="hk", phe=time)
    mx <- max(out[[k]])
    qtl <- addtoqtl(spal, qtl=qtl, chr=mx[[1]], pos=mx[[2]])
  }

  my.plot.scanone(out[[k]],  bandcol="gray70", col=color[1], ylab="", bg="gray80",
                  yaxt="n", xlab="", ylim=c(0, ymx))
  
  abline(h=thr, col=color[1], lty=2)

#  if(k>1) {
#      my.plot.scanone(out[[k-1]], col="gray50", add=TRUE)
#      my.plot.scanone(out[[k]],  col=color[1], add=TRUE)
#  }
  
  title(xlab="Chromosome", mgp=c(2, 0, 0), col.lab="Wheat")
  title(ylab="LOD score", mgp=c(1.6, 0, 0), col.lab="Wheat")
  title(main=paste("Step", k), col.main="Wheat", line=1)
  axis(side=2, at=0:6, tick=FALSE, mgp=c(0, 0.3, 0), las=1)

  xpos <- xaxisloc.scanone(out[[k]], qtl$chr, qtl$pos)
  if(k <= 2)
    points(xpos, rep(0, length(xpos)), pch=21, lwd=2, col="black",
           bg=c(rep(color[6], length(xpos)-1), color[2]))
  else # k==3
    points(xpos[1:2], rep(0, 2), pch=21, lwd=2, col="black",
           bg=color[6])

  dev.off()
}

png(file="../Figs/lodprofile.png", width=1100, height=650, pointsize=24)
par(fg="white",col="white",col.axis="white",col.lab="white",
    bg=bgcolor, mar=c(3.4, 3.1, 2.1, 0.6))

# profile LOD curves
qtl <- dropfromqtl(qtl, index=3)
prof <- attr(refineqtl(spal, phe=time, method="hk", qtl=qtl, verbose=FALSE), "lodprof")
out <- addqtl(spal, phe=time, method="hk", qtl=qtl)
outalt <- vector("list", length(prof))
ymx <- max(out[,3])
for(i in seq(along=prof)) {
  chr <- as.character(prof[[i]][1,1])
  out[out[,1]==chr,3] <- NA
  outalt[[i]] <- out
  outalt[[i]][,3] <- NA
  outalt[[i]][out[,1]==chr,3] <- prof[[i]][,3]
  ymx <- max(c(ymx, max(prof[[i]][,3])))
}
ymx <- 6 # override maximum LOD

my.plot.scanone(out,  bandcol="gray70", col="gray50", ylab="", bg="gray80",
                yaxt="n", xlab="", ylim=c(0, ymx))
abline(h=thr, col=color[1], lty=2)

for(i in 1:2) 
  my.plot.scanone(outalt[[i]], add=TRUE, col=color[i])


title(xlab="Chromosome", mgp=c(2, 0, 0), col.lab="Wheat")
title(ylab="Profile LOD score", mgp=c(1.6, 0, 0), col.lab="Wheat")
axis(side=2, at=0:6, tick=FALSE, mgp=c(0, 0.3, 0), las=1)

xpos <- xaxisloc.scanone(out, qtl$chr, qtl$pos)
points(xpos, rep(0, length(xpos)), pch=21, lwd=2, col="black",
       bg=color[1:2])


dev.off()

