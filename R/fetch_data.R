require(data.table)

MP <- "G:/Depts/EQUITY/4fquant/data/mosaic2.3/model_data/fr26/date-rgn-gics1/date-rgn-gics1/models"

# fetch analyst views
  av <- fread("data/analyst_ranks_raw.csv")
  av <- av[, .(
    date = effective_date,
    dsseccode = sym::dsseccode(as.integer(dsinfocode)),
    analyst = analyst_name,
    rec = rec,
    rank = rank
  )]
  av <- unique(av)
  fst::write_fst(av, "data/av.fst")
  av <- fst::read_fst("data/av.fst", as.data.table = TRUE)

# get esr & rtns
  btd <- btd::f4_btd(
    model_path = MP,
    model = "Total",
    universes_file = qu::f4quant("data/universes/universes.fst"),
    universe = NULL,
    start_date = min(recs$date),
    end_date = max(recs$date),
    freq = "half_year",
    min_coverage = 100L,
    return_outliers = c(-Inf, Inf),
    ccy = "usd",
    mcap_usdb = c(2, Inf),
    liq_usdm = c(5, Inf)
  )
  bt::write_btd(btd, "data/btd.fst")
  btd <- bt::read_btd("data/btd.fst")
  esr_rtn <- btd[, .(dsseccode, date, esr = fv, fwd_rtn)]
  esr_rtn <- esr_rtn[date >= av[, min(date)]]

# combine, roll recs fwd by max 1q
  comp_data <- av[esr_rtn, on = .(dsseccode, date), roll = 92L]
  comp_data[is.na(rec), rec := 0L]
  fst::write_fst(comp_data, "data/comp_data.fst")
