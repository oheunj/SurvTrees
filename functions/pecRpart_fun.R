pecRpart = function(robj, formula, data){
  data$rpartFactor = factor(predict(robj, newdata = data))
  form = update(formula, paste(".~", "rpartFactor", sep=""))
  survfit = prodlim::prodlim(form, data = data)
  out = list(rpart = robj, survfit = survfit, levels = levels(data$rpartFactor))
  class(out) = "pecRpart"
  return(out)
}
