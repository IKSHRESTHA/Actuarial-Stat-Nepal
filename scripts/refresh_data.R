# refresh_data.R — optional auto-update step.
# Wire into .github/workflows/deploy.yml (uncomment the "Refresh data" step)
# to pull the latest aggregated, ANONYMIZED data before each render.
#
# Example: a published Google Sheet (File > Share > Publish to web > CSV):
#
#   library(readr)
#   url <- Sys.getenv("SHEET_URL")        # the published CSV link
#   df  <- read_csv(url)
#   write_csv(df, "data/members.csv")
#
# Example: a members-management API:
#
#   library(httr2); library(readr)
#   resp <- request(Sys.getenv("API_URL")) |>
#     req_auth_bearer_token(Sys.getenv("API_KEY")) |> req_perform()
#   df <- resp_body_json(resp, simplifyVector = TRUE)
#   write_csv(as.data.frame(df), "data/members.csv")
#
# IMPORTANT: write ONLY aggregated / non-identifiable columns to data/members.csv.
# Strip names, emails, phone numbers and any other PII before committing.

message("Stub: implement your data source here. ",
        "The dashboard currently uses the synthetic data/members.csv.")
