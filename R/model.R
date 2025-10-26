d <- fst::read_fst("data/comp_data.fst", as.data.table = TRUE)

# normalize, annualize and put on same units
  d[, fwd_rtn := fwd_rtn - mean(fwd_rtn), by = date]
  d[, fwd_rtn := (fwd_rtn + 1)^4 - 1]
  d[, fwd_rtn := fwd_rtn * 100]
  d[, esr := ((esr/100 + 1)^2 - 1) * 100]

# split esr into pos and negative for kinked model
  d[, esr_pos := pmax(0, esr)]

m <- lm(fwd_rtn ~ esr + rec, data = d)


# check coverage
  cv <- d[!is.na(analyst), .(n_buys = sum(rec)), by = .(date, analyst)]
  dcast(cv, date ~ analyst)
