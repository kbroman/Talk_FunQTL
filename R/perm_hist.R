# Histogram of permutation distribution

# do (or load) permutations
set.seed(69456948)
load("spal.RData")
thetime <- 32

file <- "perm.RData"
if(file.exists(file)) {
  load(file)
} else {
  operm <- scanone(spal, phe=thetime, method="hk", n.perm=100000, n.cluster=8)
  operm <- as.numeric(operm)
  save(operm, file=file)
}

# make figure
source("colors.R")
color[1:2] <- c(rgb(102,203,254,maxColorValue=255),
           rgb(254,  0,128,maxColorValue=255))
bgcolor <- rgb(24, 24, 24, maxColorValue=255)

png(file="../Figs/perm_hist.png", width=900, height=725, pointsize=24)
par(fg="white",col="white",col.axis="white",col.lab="white",
    bg=bgcolor, mar=c(5.1, 0.6, 0.6, 0.6))

temp <- hist(operm, breaks=300, plot=FALSE)
x <- c(temp$breaks[1], rep(temp$breaks, rep(2, length(temp$breaks))), temp$breaks[length(temp$breaks)])
y <- c(0, 0,rep(temp$counts, rep(2, length(temp$counts))),0, 0)

plot(x, y, col=color[1], ylab="", yaxt="n", type="n", xaxs="i", yaxs="i",
     xlim=c(0, max(operm)), ylim=c(0, max(y)*1.05),
     xlab="Genome-wide maximum LOD score", mgp=c(1.7, 0.1, 0),
     tick=FALSE, col.lab=color[1])
u <- par("usr")
rect(u[1], u[3], u[2], u[4], col="gray90")
abline(v=1:6, col="white", lwd=3)
lines(x, y, lwd=2, col="darkslateblue")


dev.off()

