d <- bt::read_btd("data/wolfe-total.fst")

# add analyst recommendations
  analyst_scores <- fst::read_fst("data/analyst_scores.fst", as.data.table = TRUE)
  recs <- analyst_scores[, .(date = declaration_date, dsinfocode, rec)]
  recs[, dsseccode ]