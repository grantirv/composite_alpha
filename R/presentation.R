library(officer)
library(rvg)
library(ggplot2)

# make a ggplot
p <- ggplot(mtcars, aes(hp, mpg, color = factor(cyl))) + geom_point()

# start from a template (optional)
doc <- read_pptx() 
add_slide(doc, layout = "Title and Content", master = "Office Theme")
  ph_with_text(type = "title", str = "Editable Plot from R")

# convert ggplot -> editable PPT drawing
editable_plot <- dml(ggobj = p)     # from rvg
doc <- ph_with(doc, editable_plot, location = ph_location_type(type = "body"))

print(doc, target = "deck.pptx")

install.packages("stargazer")
library(stargazer)

m1 <- lm(mpg ~ wt + hp, data = mtcars)
m2 <- lm(mpg ~ wt + hp + am, data = mtcars)

tbl <- stargazer(m1, m2,
          type = "html",             # "text", "latex", or "html"
          se = list(NULL, NULL),     # can pass robust SEs here
          dep.var.labels = "MPG",
          covariate.labels = c("Weight", "Horsepower", "Manual"),
          omit.stat = c("f"),
          out = "stargazer_table.html")

install.packages(c("modelsummary", "sandwich", "lmtest"))

library(modelsummary)
library(sandwich)  # robust vcov
library(lmtest)

m1 <- lm(mpg ~ wt + hp, data = mtcars)
m2 <- lm(mpg ~ wt + hp + am, data = mtcars)

# Robust SEs (HC1) for each model
vcov_list <- list(m1 = vcovHC(m1, type = "HC1"),
                  m2 = vcovHC(m2, type = "HC1"))

modelsummary(
  list("Base" = m1, "Add AM" = m2),
  statistic = c("std.error", "conf.int"),  # show SE and 95% CI
  vcov = vcov_list,
  gof_map = c("nobs", "r.squared", "adj.r.squared", "rmse"),
  stars = TRUE, output = ".png"
)
