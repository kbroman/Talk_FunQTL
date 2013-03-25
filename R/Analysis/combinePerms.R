# combine permutation results

library(broman)
for(i in 1:16) {
  attachfile(i, "operm")
  if(i==1) op <- operm
  else op <- rbind(op, operm)
  detach(2)
}
operm <- op
save(operm, file="operm.RData")
