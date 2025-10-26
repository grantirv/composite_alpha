require(data.table)

# fetch analyst data
  cn <- DBI::dbConnect(odbc::odbc(), "Databricks")
  sql <- "select * from f4.analysts.analyst_scores"
  analyst_scores <- DBI::dbGetQuery(cn, sql) |> as.data.table()
  fst::write_fst(analyst_scores, "data/analyst_scores.fst")

# create recommendation data
  recs <- analyst_scores[, .(
    date = declaration_date,
    dsseccode = sym::dsseccode(as.integer(dsinfocode)),
    analyst = analyst_name,
    rec = rec
  )]
  recs <- unique(recs)
  fst::write_fst(recs, "data/recs.fst")

# get esr & rtns
  btd <- bt::read_btd("data/global-total.fst")
  esr_rtn <- btd[, .(dsseccode, date, esr = fv, fwd_rtn)]
  esr_rtn <- esr_rtn[date >= recs[, min(date)]]

# combine, roll recs fwd by max 1q
  comp_data <- recs[esr_rtn, on = .(dsseccode, date), roll = 92L]
  comp_data[is.na(rec), rec := 0L]
  fst::write_fst(comp_data, "data/comp_data.fst")

