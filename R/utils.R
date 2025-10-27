conviction_score <- function(x) {
  r <- frank(x, ties.method = "min")
  max_r <- max(r)
  prob <- (r - 0.5) / max_r
  conv <- qnorm(prob) * -1
  return(conv)
}
