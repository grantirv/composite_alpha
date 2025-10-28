d <- fst::read_fst("data/comp_data.fst", as.data.table = TRUE)

# convert to log returns
  d[, fwd_rtn := log(1 + fwd_rtn) * 100]
  d[, esr := log((1 + esr/100)) * 100]
  
# remove return outliers
  d <- d[fwd_rtn > -100 & fwd_rtn < 100]

# demean fwd_rtn & esr by date
  d[, fwd_rtn := fwd_rtn - mean(fwd_rtn), by = date]
  d[, esr := esr - mean(esr, na.rm = TRUE), by = date]

# split esr into pos and negative for kinked model
  d[, esr_pos := pmax(0, esr)]
  d[, esr_neg := pmin(0, esr)]

# calculate conviction score for each analyst
  d[, conv := conviction_score(rank), by = .(date, analyst)]

# separate recommendations into buys and sells
  d[, buy := ifelse(rec == 1, 1, 0)]
  d[, sell := ifelse(rec == -1, 1, 0)]

# fit model
  models <- list(
    m1 = lm(fwd_rtn ~ 0 + esr, data = d),
    m2 = lm(fwd_rtn ~ 0 + esr_pos + esr_neg, data = d),
    m3 = lm(fwd_rtn ~ 0 + esr_pos + esr_neg + buy, data = d),
    m4 = lm(fwd_rtn ~ 0 + esr_pos + esr_neg + buy + sell, data = d),
    m5 = lm(fwd_rtn ~ 0 + esr_pos + esr_neg + buy + sell + conv, data = d)
  )
  
# summarize results
  summary(m1)
  summary(m2)

# plot predictions
  MINTY <- rgb(137/255, 192/255, 174/255)
  coef <- m2$coefficients
  d[, esr_ctb := ifelse(esr > 0, esr_pos * coef['esr_pos'], esr_neg * coef['esr_neg'])]
  d[, rec_ctb := rec * coef['rec']]
  pd <- d[date == max(date), .(esr, esr_ctb, rec_ctb, buy = rec > 0)]

  library(ggplot2)
  p <- ggplot(pd, aes(x = esr, y = esr_ctb))
  p <- p + geom_line()
  p <- p + geom_linerange(
    mapping = aes(x = esr, ymin = esr_ctb, ymax = esr_ctb + rec_ctb),
    data = pd[rec_ctb != 0],
    colour = MINTY
  )
  p <- p + geom_point(
    mapping = aes(x = esr, y = esr_ctb + rec_ctb),
    data = pd[rec_ctb != 0],
    colour = MINTY
  )

  p <- p + xlim(-0.05, 0.05)



  p <- p + geom_col() + xlim(-0.02, 0.05)


    geom_line(aes(y = pred1), color = "blue") +
    geom_line(aes(y = pred2), color = "red") +
    labs(title = "Predicted vs Actual Forward Returns",
         x = "Earnings Surprise (ESR)",
         y = "Forward Log Return") +
    theme_minimal()





# check coverage
  cv <- d[!is.na(analyst), .(n_buys = sum(rec)), by = .(date, analyst)]
  dcast(cv, date ~ analyst)
