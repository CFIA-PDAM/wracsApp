# profiling/profile-app.R
#
# End-to-end app profiling. Boots the actual Shiny app under profvis and
# drives it with shinytest2, mimicking a real user session.

suppressPackageStartupMessages({
  library(profvis)
  library(shiny)
  library(shinytest2)
  library(htmlwidgets)
})

results_dir <- fs::path(here::here(), "profiling", "results")
dir.create(results_dir, showWarnings = FALSE, recursive = TRUE)

occurrence_data <- file.path(testthat::test_path("bral.xlsx"))
stopifnot(file.exists(occurrence_data))

missing_data <- file.path(testthat::test_path("test_file.xlsx"))
stopifnot(file.exists(missing_data))

# ---- End-to-end run under profvis ---------------------------------------
# Note: we wrap the AppDriver session in profvis. Everything the R process
# does — server function, reactives, render*, downloadHandler — is sampled.

p_app <- profvis::profvis(
  prof_output = file.path(results_dir, "e2e.Rprof"),
  expr = {
    app <- shinytest2::AppDriver$new(
      app_dir = ".",
      name = "geospatial-weed-risk-e2e",
      load_timeout = 60 * 1000,
      timeout = 30 * 1000,
      seed = 42,
      view = FALSE,
      options = list(shiny.testmode = TRUE)
    )
    on.exit(try(app$stop(), silent = TRUE), add = TRUE)

    # 1. Initial load — upload modal should be present.
    app$wait_for_idle()

    app$wait_for_js(
      "document.querySelector('.modal') !== null"
    )

    app$wait_for_js(
      "document.querySelector('#upload-occurrence_data_uploaded') !== null"
    )

    # 2. Upload the fixture file.
    app$upload_file(`upload-occurrence_data_uploaded` = occurrence_data)
    app$wait_for_idle()

    # 3. Dismiss the modal.
    app$click("upload-close_modal", wait_ = FALSE)
    app$wait_for_idle()

    # 4. Sidebar filters — currently not bound to any output.
    app$set_inputs(
      quality_control_filter = c("Cult", "iNat"),
      wait_ = FALSE
    )
    app$set_inputs(
      basis_of_record_filter = c("HUMAN_OBSERVATION", "PRESERVED_SPECIMEN"),
      wait_ = FALSE
    )
    Sys.sleep(6) # honour the 5s debounce mentioned in the UI tooltip
    app$wait_for_idle()

    # 5. Walk every nav panel.
    nav_panels <- c(
      "1 Occurrence Data",
      "2 Data Summary",
      "3 Map",
      "4 Koppen-Geiger Table",
      "5 Plant Hardiness Table",
      "6 Precipitation Bands Table",
      "7 Map Worksheet",
      "8 Suitability Maps"
    )
    for (panel in nav_panels) {
      app$set_inputs(tabs = panel, wait_ = FALSE)
      app$wait_for_idle()
    }

    # 6. Plot-settings + map-settings tweaks.
    app$set_inputs(plot_occurrence_data = "TRUE", wait_ = FALSE)
    app$set_inputs(marker_id = "12345", wait_ = FALSE)
    app$click("restore_clicked_ids", wait_ = FALSE)
    app$wait_for_idle()

    # 7. Exercise the download handler.
    app$set_inputs(sidebar_settings = c("Occurrence Data", "Plot Settings"))
    dl_path <- app$get_download("export_analysis_files")
    stopifnot(file.exists(dl_path))

    # 8. Reopen the upload modal.
    app$click("reopen_upload_modal", wait_ = FALSE)
    app$wait_for_idle()

    app$stop()
  }
)

out_html <- fs::path(results_dir, "e2e-app.html")
htmlwidgets::saveWidget(p_app, out_html, selfcontained = TRUE)
message("Saved: ", out_html)
message("Raw Rprof: ", file.path(results_dir, "e2e.Rprof"))
