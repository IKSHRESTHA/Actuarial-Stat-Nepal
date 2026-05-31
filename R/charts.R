# charts.R — one function per visual, best tool per chart
# ggiraph: statistical ggplots w/ tooltips | highcharter: donuts & growth
# leaflet: map | gt: tables

suppressPackageStartupMessages({
  library(ggiraph); library(highcharter); library(leaflet); library(gt)
})

# ---- highcharter dark theme matching the brand ----
hc_asn <- function(hc) {
  hc |>
    hc_chart(backgroundColor = "transparent",
             style = list(fontFamily = "Ashwin, sans-serif")) |>
    hc_colors(asn_series) |>
    hc_title(text = "") |>
    hc_credits(enabled = FALSE) |>
    hc_legend(itemStyle = list(color = asn$navy, fontWeight = "700"),
          itemHoverStyle = list(color = asn$navy)) |>
    hc_tooltip(backgroundColor = asn$ink, borderColor = asn$gold,
           style = list(color = asn$paper, fontWeight = "700"),
               useHTML = TRUE) |>
    hc_plotOptions(series = list(animation = list(duration = 900)))
}

# ===== OVERVIEW =====

# Membership category — highcharter donut with center total
hc_category <- function() {
  d <- members |> count(Category) |>
    mutate(Category = as.character(Category))
  highchart() |> hc_asn() |>
    hc_chart(type = "pie") |>
    hc_plotOptions(pie = list(center = list("50%", "50%"))) |>
    hc_add_series(
      data = lapply(seq_len(nrow(d)), function(i)
        list(name = d$Category[i], y = d$n[i])),
      innerSize = "62%", name = "Members",
      dataLabels = list(enabled = TRUE,
        format = "{point.name}: <b>{point.percentage:.0f}%</b>",
        distance = 16, allowOverlap = FALSE,
        connectorColor = asn$muted, connectorWidth = 1,
        style = list(color = asn$navy, textOutline = "none",
                     fontSize = "12px", fontWeight = "700"))) |>
    hc_subtitle(text = paste0(
      "<div style='text-align:center'>",
      "<div style='font-family:Ashwin;font-weight:700;",
      "font-size:30px;color:", asn$navy, "'>", kpi$total,
      "</div><div style='font-size:11px;font-weight:600;letter-spacing:.1em;color:",
      asn$navy2, "'>MEMBERS</div></div>"),
      useHTML = TRUE, align = "center", verticalAlign = "middle", y = 0)
}

# Gender — highcharter donut
hc_gender <- function() {
  d <- members |> count(Gender)
  highchart() |> hc_asn() |>
    hc_chart(type = "pie") |>
    hc_plotOptions(pie = list(center = list("50%", "50%"))) |>
    hc_colors(c(asn$teal, asn$gold)) |>
    hc_add_series(
      data = lapply(seq_len(nrow(d)), function(i)
        list(name = d$Gender[i], y = d$n[i])),
      innerSize = "62%", name = "Members",
      dataLabels = list(enabled = TRUE,
        format = "{point.name}: <b>{point.percentage:.0f}%</b>",
        distance = 16, allowOverlap = FALSE,
        connectorColor = asn$muted, connectorWidth = 1,
        style = list(color = asn$navy, textOutline = "none",
                     fontSize = "12px", fontWeight = "700"))) |>
    hc_subtitle(text = paste0(
      "<div style='text-align:center'>",
      "<div style='font-family:Ashwin;font-weight:700;",
      "font-size:30px;color:", asn$navy, "'>", kpi$total,
      "</div><div style='font-size:11px;font-weight:600;letter-spacing:.1em;color:",
      asn$navy2, "'>MEMBERS</div></div>"),
      useHTML = TRUE, align = "center", verticalAlign = "middle", y = 0)
}

# ===== PATHWAY & EXAMS =====

# Papers passed — ggiraph lollipop with qualification markers
gg_papers <- function() {
  brks <- c(-1, 3, 6, 9, 12, 16)
  labs <- c("0–3","4–6","7–9","10–12","13–15")
  d <- members |>
    mutate(band = cut(PapersPassed, breaks = brks, labels = labs)) |>
    count(band) |> tidyr::complete(band = labs, fill = list(n = 0)) |>
    mutate(band = factor(band, levels = labs),
           tip = paste0(band, " papers: ", n, " members"))
  p <- ggplot(d, aes(band, n)) +
    geom_segment(aes(xend = band, yend = 0),
           colour = scales::alpha(asn$gold, 0.45), linewidth = 1.4) +
    geom_point_interactive(aes(tooltip = tip, data_id = band),
           size = 7, colour = asn$gold) +
    geom_text(aes(label = n), vjust = -1.4, colour = asn$navy,
          family = "Ashwin", fontface = "bold", size = 4) +
    geom_vline(xintercept = 1.5, linetype = "dotted",
           colour = asn$teal, linewidth = .5) +
    annotate("text", x = 1.5, y = max(d$n), label = "Associate \u2265",
         colour = asn$navy, family = "Ashwin", fontface = "bold", size = 3, hjust = 1.05) +
    scale_y_continuous(expand = expansion(mult = c(0, .18))) +
    labs(x = NULL, y = "Members") + theme_asn()
  girafe(ggobj = p, width_svg = 7, height_svg = 3.4,
         options = gir_opts())
}

# Education — ggiraph horizontal bar
gg_education <- function() {
  d <- members |> count(Education) |>
    mutate(tip = paste0(Education, ": ", n))
  p <- ggplot(d, aes(n, fct_rev(Education))) +
    geom_col_interactive(aes(tooltip = tip, data_id = Education,
                             fill = Education), width = .66) +
    geom_text(aes(label = n), hjust = -.3, colour = asn$navy,
          family = "Ashwin", fontface = "bold", size = 4) +
    scale_fill_manual(values = asn_series, guide = "none") +
    scale_x_continuous(expand = expansion(mult = c(0, .12))) +
    labs(x = NULL, y = NULL) + theme_asn()
  girafe(ggobj = p, width_svg = 6, height_svg = 3, options = gir_opts())
}

# Exam system — highcharter donut
hc_examsys <- function() {
  d <- members |> count(ExamSystem)
  highchart() |> hc_asn() |>
    hc_chart(type = "pie") |>
    hc_add_series(
      data = lapply(seq_len(nrow(d)), function(i)
        list(name = d$ExamSystem[i], y = d$n[i])),
      innerSize = "55%", name = "Members",
      dataLabels = list(enabled = TRUE,
        format = "{point.name}<br>{point.percentage:.0f}%",
        style = list(color = asn$navy, textOutline = "none",
                     fontSize = "11px", fontWeight = "700")))
}

# ===== PROFESSIONAL PRACTICE =====

# Area of practice — ggiraph gradient bar
gg_practice <- function() {
  d <- members |> count(AreaOfPractice) |>
    mutate(AreaOfPractice = fct_reorder(AreaOfPractice, n),
           tip = paste0(AreaOfPractice, ": ", n))
  p <- ggplot(d, aes(n, AreaOfPractice)) +
    geom_col_interactive(aes(tooltip = tip, data_id = AreaOfPractice,
                             fill = n), width = .72) +
    geom_text(aes(label = n), hjust = -.3, colour = asn$navy,
          family = "Ashwin", fontface = "bold", size = 3.6) +
    scale_fill_gradient(low = asn$navy_soft, high = asn$gold, guide = "none") +
    scale_x_continuous(expand = expansion(mult = c(0, .12))) +
    labs(x = NULL, y = NULL) + theme_asn()
  girafe(ggobj = p, width_svg = 6.4, height_svg = 4.4, options = gir_opts())
}

# Other memberships — highcharter column
hc_dual <- function() {
  d <- members |> filter(OtherMembership != "Independent") |>
    count(OtherMembership) |> arrange(desc(n))
  highchart() |> hc_asn() |>
    hc_chart(type = "column") |>
    hc_xAxis(categories = d$OtherMembership,
             labels = list(style = list(color = asn$navy, fontWeight = "700")),
             lineColor = scales::alpha(asn$navy_soft, 0.2)) |>
    hc_yAxis(title = list(text = ""), gridLineColor = scales::alpha(asn$navy_soft, 0.12),
             labels = list(style = list(color = asn$navy, fontWeight = "700"))) |>
    hc_add_series(data = d$n, name = "Members", color = asn$teal,
                  showInLegend = FALSE,
                  dataLabels = list(enabled = TRUE,
                    style = list(color = asn$navy, textOutline = "none",
                                 fontWeight = "700")))
}

# ===== DEMOGRAPHICS =====

# Age groups — ggiraph bar
gg_age <- function() {
  d <- members |> count(AgeGroup) |>
    mutate(tip = paste0("Age ", AgeGroup, ": ", n))
  p <- ggplot(d, aes(AgeGroup, n)) +
    geom_col_interactive(aes(tooltip = tip, data_id = AgeGroup,
                             fill = AgeGroup), width = .68) +
    geom_text(aes(label = n), vjust = -.8, colour = asn$navy,
          family = "Ashwin", fontface = "bold", size = 4) +
    scale_fill_manual(values = asn_series, guide = "none") +
    scale_y_continuous(expand = expansion(mult = c(0, .15))) +
    labs(x = NULL, y = NULL) + theme_asn()
  girafe(ggobj = p, width_svg = 6, height_svg = 3.2, options = gir_opts())
}

# Category by gender — ggiraph stacked bar
gg_gender_cat <- function() {
  d <- members |> count(Category, Gender) |>
    mutate(tip = paste0(Gender, " ", Category, ": ", n))
  p <- ggplot(d, aes(Category, n, fill = Gender)) +
    geom_col_interactive(aes(tooltip = tip,
                             data_id = interaction(Category, Gender)),
                         width = .66) +
    scale_fill_manual(values = c(Female = asn$teal, Male = asn$gold)) +
    scale_y_continuous(expand = expansion(mult = c(0, .08))) +
    labs(x = NULL, y = NULL) + theme_asn()
  girafe(ggobj = p, width_svg = 6, height_svg = 3.2, options = gir_opts())
}

# ===== GROWTH =====

# Growth — highcharter combo (column new + line cumulative)
hc_growth <- function() {
  d <- members |> count(JoinYear, name = "new") |> arrange(JoinYear)
  yrs <- seq(min(d$JoinYear), 2025)
  d <- tibble(JoinYear = yrs) |> left_join(d, by = "JoinYear") |>
    mutate(new = tidyr::replace_na(new, 0), cum = cumsum(new))
  highchart() |> hc_asn() |>
    hc_xAxis(categories = d$JoinYear,
               labels = list(style = list(color = asn$navy, fontWeight = "700")),
               lineColor = scales::alpha(asn$navy_soft, 0.2)) |>
            hc_yAxis(title = list(text = ""), gridLineColor = scales::alpha(asn$navy_soft, 0.12),
               labels = list(style = list(color = asn$navy, fontWeight = "700"))) |>
    hc_add_series(name = "New members", type = "column",
                 data = d$new, color = scales::alpha(asn$teal, 0.55)) |>
    hc_add_series(name = "Cumulative", type = "spline",
                 data = d$cum, color = asn$gold,
                 marker = list(fillColor = asn$gold_soft, radius = 4)) |>
    hc_legend(enabled = TRUE)
}

# ===== GEOGRAPHY =====

prov_coord <- tribble(
  ~Province,        ~lat,   ~lng,
  "Bagmati",        27.70,  85.32,
  "Gandaki",        28.21,  83.99,
  "Koshi",          26.45,  87.28,
  "Lumbini",        27.70,  83.45,
  "Madhesh",        26.73,  85.92,
  "Sudurpashchim",  28.70,  80.59,
  "Karnali",        28.60,  82.18
)

leaflet_nepal <- function() {
  d <- members |> filter(Province != "International") |>
    count(Province) |> left_join(prov_coord, by = "Province")
  leaflet(d, options = leafletOptions(scrollWheelZoom = TRUE)) |>
    addProviderTiles("CartoDB.DarkMatter") |>
    setView(lng = 84, lat = 28.2, zoom = 6) |>
    addCircleMarkers(
      lng = ~lng, lat = ~lat,
      radius = ~8 + sqrt(n) * 2.2,
      color = asn$gold, weight = 2,
      fillColor = asn$gold, fillOpacity = .35,
      label = ~lapply(paste0("<span style='color:", asn$navy,
                             ";font-weight:700'>", Province,
                             ": <b>", n, "</b> members</span>"),
                      htmltools::HTML))
}

# City table — gt
gt_cities <- function() {
  members |> count(Province, City, name = "Members") |>
    arrange(desc(Members)) |> head(12) |>
    gt() |>
    tab_header(title = "Top Cities") |>
    cols_label(Members = "Members") |>
    data_color(columns = Members,
           fn = scales::col_numeric(c(asn$navy_soft, asn$gold),
                                        domain = NULL)) |>
    tab_options(
      table.background.color = "transparent",
      table.font.names = "Ashwin",
      table.font.color = asn$navy,
      table.border.top.style = "none",
      table.border.bottom.style = "none",
      column_labels.background.color = asn$navy2,
      column_labels.font.weight = "700",
      heading.title.font.size = px(15),
      heading.background.color = "transparent",
      table_body.hlines.color = scales::alpha(asn$navy_soft, 0.12),
      table.font.size = px(13)
    ) |>
    tab_style(
      style = cell_text(weight = "700", color = asn$navy),
      locations = list(cells_body(), cells_column_labels(), cells_title())
    )
}
