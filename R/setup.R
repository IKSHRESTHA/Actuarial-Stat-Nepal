# setup.R — shared palette, ggplot theme, data loading
# Sourced by index.qmd

suppressPackageStartupMessages({
  library(readr); library(dplyr); library(tidyr); library(forcats)
  library(stringr); library(scales); library(ggplot2)
})

# Register the Ashwin web font so it embeds inside ggplot/ggiraph SVGs.
# Optional: if showtext isn't installed, charts fall back to a default font
# for axis text (the rest of the page still uses Ashwin via the web font).
if (requireNamespace("showtext", quietly = TRUE) &&
    requireNamespace("sysfonts", quietly = TRUE)) {
  try({
    sysfonts::font_add_google("Ashwin", "Ashwin")
    showtext::showtext_auto()
  }, silent = TRUE)
}

# ---- Brand palette ----
asn <- list(
  navy      = "#0B1F3A",
  navy2     = "#0E2647",
  navy_soft = "#142B4D",
  gold      = "#8A6F2A",
  gold_soft = "#A8893A",
  teal      = "#1F5D57",
  blue      = "#2B3F7A",
  plum      = "#4A3F6D",
  rose      = "#6B3B33",
  ink       = "#0A1426",
  paper     = "#D6DAE6",
  muted     = "#4B5563"
)
asn_series <- c(asn$gold, asn$teal, asn$blue, asn$rose, asn$plum,
                asn$gold_soft, "#2F6B63", asn$navy_soft)

# ---- Data ----
members <- read_csv("data/members.csv", show_col_types = FALSE) |>
  mutate(
    Category   = factor(Category, levels = c("Fellow","Associate","Student","Affiliate")),
    AgeGroup   = factor(AgeGroup, levels = c("20-29","30-39","40-49","50-59","60+")),
    Education  = factor(Education, levels = c("Bachelor","Master","PhD","Other"))
  )

# ---- KPIs ----
kpi <- list(
  total       = nrow(members),
  fellows     = sum(members$Category == "Fellow"),
  associates  = sum(members$Category == "Associate"),
  students    = sum(members$Category == "Student"),
  affiliates  = sum(members$Category == "Affiliate"),
  female_pct  = round(mean(members$Gender == "Female") * 100),
  dual_pct    = round(mean(members$OtherMembership != "Independent") * 100),
  avg_papers  = round(mean(members$PapersPassed), 1),
  countries   = members |> filter(Province == "International") |>
                  distinct(City) |> nrow() + 1
)

# ---- ggplot theme: dark editorial ----
theme_asn <- function(base_size = 13) {
  theme_minimal(base_size = base_size, base_family = "Ashwin") +
    theme(
      text = element_text(colour = asn$navy, face = "bold"),
      plot.background  = element_rect(fill = "transparent", colour = NA),
      panel.background = element_rect(fill = "transparent", colour = NA),
      panel.grid.major = element_line(colour = scales::alpha(asn$navy_soft, 0.22), linewidth = .3),
      panel.grid.minor = element_blank(),
      axis.text   = element_text(colour = asn$navy, size = rel(.9), face = "bold"),
      axis.title  = element_text(colour = asn$navy, size = rel(.85), face = "bold"),
      plot.title  = element_blank(),
      legend.position = "bottom",
      legend.title = element_blank(),
      legend.text  = element_text(colour = asn$navy, size = rel(.85), face = "bold"),
      legend.key   = element_rect(fill = "transparent", colour = NA),
      plot.margin  = margin(6, 10, 6, 6)
    )
}

# helper: girafe options for consistent interactive styling
gir_opts <- function() {
  list(
    ggiraph::opts_tooltip(
      css = paste0("background:", asn$ink, ";color:", asn$paper,
           ";border:1px solid ", asn$gold,
                   ";border-radius:8px;padding:6px 10px;",
                   "font-family:Ashwin, sans-serif;font-size:13px;font-weight:700;"),
      opacity = .98),
    ggiraph::opts_hover(css = "filter:brightness(1.15);cursor:pointer;"),
    ggiraph::opts_toolbar(saveaspng = FALSE)
  )
}
