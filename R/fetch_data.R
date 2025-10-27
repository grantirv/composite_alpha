require(data.table)

# fetch analyst data
  cn <- DBI::dbConnect(odbc::odbc(), "Databricks")
  sql <- "select * from f4.analysts.analyst_scores"
  analyst_scores <- DBI::dbGetQuery(cn, sql) |> as.data.table()
  fst::write_fst(analyst_scores, "data/analyst_scores.fst")
  analyst_scores <- fst::read_fst("data/analyst_scores.fst", as.data.table = TRUE)

# create recommendation data
  recs <- analyst_scores[, .(
    date = declaration_date,
    dsseccode = sym::dsseccode(as.integer(dsinfocode)),
    analyst = analyst_name,
    rec = rec
  )]
  recs <- unique(recs)
  fst::write_fst(recs, "data/recs.fst")
  recs <- fst::read_fst("data/recs.fst", as.data.table = TRUE)

# get esr & rtns
  btd <- bt::read_btd("data/wolfe_investible-total.fst")
  esr_rtn <- btd[, .(dsseccode, date, esr = fv, fwd_rtn)]
  esr_rtn <- esr_rtn[date >= recs[, min(date)]]

# combine, roll recs fwd by max 1q
  comp_data <- recs[esr_rtn, on = .(dsseccode, date), roll = 92L]
  comp_data[is.na(rec), rec := 0L]
  fst::write_fst(comp_data, "data/comp_data.fst")

