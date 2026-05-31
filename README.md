# ASN Membership Dashboard (R)

A polished, fully-static public dashboard for the **Actuarial Society of Nepal**, built in **R**
with Quarto and hosted free on **GitHub Pages**. Every chart is client-side interactive, so no
server is needed.

Built with the best R tool for each job:

| Element | Package |
|---|---|
| Statistical charts (papers, education, age, practice, gender×category) | **ggplot2 + ggiraph** (tooltips) |
| Donuts & combo growth chart | **highcharter** |
| Nepal map | **leaflet** (free CartoDB dark tiles, no API key) |
| Top-cities summary table | **gt** |
| Searchable data table | **reactable** |
| Theme / fonts | custom **SCSS** (Ashwin display font + Spline Sans body) |

## What's inside

```
asn-dashboard-r/
├── index.qmd                 # the dashboard (hero + 7 tabs)
├── R/
│   ├── setup.R               # palette, ggplot theme, data loading, KPIs
│   └── charts.R              # every chart/table function (edit charts here)
├── theme.scss                # custom navy/gold editorial theme + Ashwin font
├── _quarto.yml               # project config
├── data/
│   ├── members.csv           # SYNTHETIC anonymized data — swap for real aggregates
│   └── ASN_membership_data.xlsx  # same data as a styled Excel workbook
├── scripts/refresh_data.R    # optional auto-update data puller (stub)
└── .github/workflows/deploy.yml  # CI: render + deploy to Pages (daily + on push)
```

## Run locally

1. Install [R](https://cran.r-project.org/), [Quarto](https://quarto.org/docs/get-started/),
   and the packages:

   ```r
   install.packages(c(
     "readr","dplyr","tidyr","forcats","stringr","scales","ggplot2",
     "ggiraph","highcharter","leaflet","gt","reactable","htmltools","htmlwidgets"
   ))
   ```

2. From this folder:

   ```bash
   quarto preview     # live preview
   # or
   quarto render      # builds _site/
   ```

### Font note (Ashwin)

The charts render text in **Ashwin** (a Google Font). For it to appear inside the
**ggplot/ggiraph** SVGs when rendering locally, register it once per session:

```r
# install.packages("showtext")  # if needed
library(showtext)
font_add_google("Ashwin", "Ashwin")
showtext_auto()
```

The `index.qmd` already sets `fig.showtext: true`. If you skip this, charts still render —
ggplot just falls back to a default font for axis text, while the rest of the page (HTML,
highcharter, gt, reactable) uses Ashwin via the loaded web font. On GitHub Actions add the same
two `showtext` lines to the top of `R/setup.R` if you want the embedded font in chart SVGs there too.

## Deploy to GitHub Pages (free)

1. Push this folder to a GitHub repo's `main` branch.
2. **Settings → Pages → Build and deployment → Source = GitHub Actions**.
3. The included workflow renders and deploys on every push, **plus a daily rebuild**
   (02:00 UTC). You can also trigger it manually from the **Actions** tab.

Site URL: `https://<username>.github.io/<repo>/`.

## Swapping in real data

`data/members.csv` is **synthetic**. Replace it with your own aggregated, **non-identifiable**
export using the same columns:

`MemberID, Category, Gender, AgeGroup, Education, PapersPassed, ExamSystem,`
`AreaOfPractice, OtherMembership, Province, City, JoinYear`

- `Category`: Fellow / Associate / Student / Affiliate
- `OtherMembership`: an actuarial body, or `Independent` if none

To auto-pull on each rebuild, fill in `scripts/refresh_data.R` (Google Sheets / API examples
included) and uncomment the *Refresh data* step in the workflow.

## Customizing

- **Colors & fonts:** the `asn` palette list at the top of `R/setup.R`, and the SCSS variables in
  `theme.scss`.
- **Charts:** every visual is a function in `R/charts.R`. ggplot charts share `theme_asn()`;
  highcharter charts share `hc_asn()`. Add or edit freely, then reference in `index.qmd`.
- **Tabs / copy / icons:** edit `index.qmd`. Icons are [Bootstrap Icons](https://icons.getbootstrap.com/)
  via `<i class="bi bi-...">`.

## Notes

- No PII should ever be committed; keep `data/members.csv` aggregated.
- The map uses free CartoDB/OpenStreetMap tiles — no API key.
- Everything is static HTML + JS, perfect for GitHub Pages.
