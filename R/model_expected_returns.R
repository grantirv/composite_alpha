require(data.table)

# fetch analyst data
  cn <- DBI::dbConnect(odbc::odbc(), "Databricks")
  sql <- "select * from f4.analysts.analyst_scores"
  analyst_scores <- DBI::dbGetQuery(cn, sql) |> as.data.table()
  fst::write_fst(analyst_scores, "data/analyst_scores.fst")






  