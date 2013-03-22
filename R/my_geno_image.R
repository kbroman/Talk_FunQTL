# slightly revised version of geno.image() in R/qtl, www.rqtl.org
my.geno.image <- 
function (x, chr, reorder = FALSE, main = "", alternate.chrid = FALSE, 
    ...) 
{
    cross <- x
    if (!any(class(cross) == "cross")) 
        stop("Input should have class \"cross\".")
    if (!missing(chr)) 
        cross <- subset(cross, chr = chr)
    type <- class(cross)[1]
    if (type == "bc" || type == "f2") {
        chrtype <- sapply(cross$geno, class)
        if (any(chrtype == "X")) {
            for (i in which(chrtype == "X")) cross$geno[[i]]$data <- reviseXdata(type, 
                "simple", getsex(cross), geno = cross$geno[[i]]$data, 
                cross.attr = attributes(cross))
        }
    }
    Geno <- pull.geno(cross)
    if (type != "4way") {
        thecolors <- c("white", "#E41A1C", "#377EB8", "#4DAF4A", 
            "#984EA3", "#FF7F00")
        thebreaks <- seq(-0.5, 5.5, by = 1)
    }
    else {
        if (max(Geno, na.rm = TRUE) <= 5) {
            thecolors <- c("white", "#E41A1C", "#377EB8", "#4DAF4A", 
                "#984EA3", "#FF7F00")
            thebreaks <- seq(-0.5, 5.5, by = 1)
        }
        else {
            thecolors <- c("white", "#8DD3C7", "#FFFFB3", "#BEBADA", 
                "#FB8072", "#80B1D3", "#FDB462", "#B3DE69", "#FCCDE5", 
                "#D9D9D9", "#BC80BD")
            thebreaks <- seq(-0.5, 10.5, by = 1)
        }
    }
    thecolors[1:3] <- c(rgb(24, 24, 24, maxColorValue=255),
                   rgb(102,203,254,maxColorValue=255),
                   rgb(254,  0,128,maxColorValue=255))

    o <- 1:nrow(Geno)
    if (reorder) {
        if (is.numeric(reorder)) {
            if (reorder < 1 || reorder > nphe(cross)) 
                stop("reorder should be TRUE, FALSE, or an integer between 1 and", 
                  nphe(cross))
            o <- order(cross$pheno[, reorder])
        }
        else {
            wh <- sapply(cross$pheno, is.numeric)
            o <- order(apply(cross$pheno[, wh, drop = FALSE], 
                1, sum))
        }
    }
    g <- t(Geno[o, ])
    g[is.na(g)] <- 0
    old.xpd <- par("xpd")
    old.las <- par("las")
    par(xpd = TRUE, las = 1)
    on.exit(par(xpd = old.xpd, las = old.las))
    image(1:nrow(g), 1:ncol(g), g, ylab = "Lines", xlab = "Markers", 
        col = thecolors, breaks = thebreaks)
    n.mar <- nmar(cross)
    n.chr <- nchr(cross)
    a <- c(0.5, cumsum(n.mar) + 0.5)
    b <- par("usr")
    segments(a, b[3], a, b[4] + diff(b[3:4]) * 0.02)
    abline(h = 0.5 + c(0, ncol(g)), xpd = FALSE)
    a <- par("usr")
    wh <- cumsum(c(0.5, n.mar))
    x <- 1:n.chr
    for (i in 1:n.chr) x[i] <- mean(wh[i + c(0, 1)])
    thechr <- names(cross$geno)
    if (!alternate.chrid || length(thechr) < 2) {
        for (i in seq(along = x)) axis(side = 3, at = x[i], thechr[i], 
            tick = FALSE, line = -0.5)
    }
    else {
        odd <- seq(1, length(x), by = 2)
        even <- seq(2, length(x), by = 2)
        for (i in odd) axis(side = 3, at = x[i], labels = thechr[i], 
            line = -0.75, tick = FALSE)
        for (i in even) axis(side = 3, at = x[i], labels = thechr[i], 
            line = +0, tick = FALSE)
    }
    title(main = main)
    invisible()
}
