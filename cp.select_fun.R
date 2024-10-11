cp.select = function(big.tree) {
  min.x = which.min(big.tree$cptable[, 4])
  for(i in 1:nrow(big.tree$cptable)) {
    if(big.tree$cptable[i, 4] < big.tree$cptable[min.x, 4] + big.tree$cptable[min.x, 5]) 
      return(big.tree$cptable[i, 1])
  }
}