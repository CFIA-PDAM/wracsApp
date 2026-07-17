# profiling/profile-components.R
#
# Component-level profiling. Each block isolates a single piece of the app
# so its cost can be attributed precisely, similar to unit tests.

suppressPackageStartupMessages({
  library(profvis)
  library(shiny)
  library(htmlwidgets)
})

# ---- Setup ---------------------------------------------------------------

results_dir <- fs::path(here::here(), "profiling", "results")
dir.create(results_dir, showWarnings = FALSE, recursive = TRUE)

occurrence_data <- fs::path(testthat::test_path("bral.xlsx"))
stopifnot(file.exists(occurrence_data))

missing_data <- fs::path(testthat::test_path("test_file.xlsx"))
stopifnot(file.exists(missing_data))

save_prof <- function(p, name) {
  out <- fs::path(results_dir, paste0(name, ".html"))
  htmlwidgets::saveWidget(p, out, selfcontained = TRUE)
  message("Saved: ", out)
}

# ---- 1. global.R sourcing ------------------------------------------------
# Measures the cost of constructing the lookup tables / constants on startup.

p_global <- profvis::profvis({
  for (i in seq_len(50)) {
    e <- new.env()
    sys.source(fs::path("R", "global.R"), envir = e)
  }
})
save_prof(p_global, "01-global-sourcing")

# ---- 2. UI construction --------------------------------------------------
# Re-evaluates ui.R repeatedly so any bslib/htmltools overhead is visible.

p_ui <- profvis::profvis({
  sys.source(fs::path("R", "global.R"), envir = globalenv())
  for (i in seq_len(20)) {
    ui_env <- new.env(parent = globalenv())
    sys.source(fs::path("R", "ui.R"), envir = ui_env)
    # Force the lazily evaluated tag tree to be rendered to HTML.
    invisible(as.character(ui_env$ui))
  }
})
save_prof(p_ui, "02-ui-construction")

# ---- 3. xlsx ingestion ---------------------------------------------------
# Mirrors what `input$occurrence_data_uploaded` triggers in the module:
# read the file, compare names, surface the missing-columns diff.

p_ingest <- profvis::profvis({
  sys.source(fs::path("R", "global.R"), envir = globalenv())
  for (i in seq_len(10)) {
    df_head <- readxl::read_excel(occurrence_data, n_max = 1)
    missing <- setdiff(occurrence_data_column_names, names(df_head))
    df_full <- readxl::read_excel(occurrence_data, guess_max = 10000)
  }
})
save_prof(p_ingest, "03-xlsx-ingestion")

# ---- 4. Upload module server ---------------------------------------------
# Drives `ingest_occurrence_data_server()` through shiny::testServer() so
# every reactive path (success + failure) is profiled in isolation.

sys.source(fs::path("R", "global.R"), envir = globalenv())
sys.source(fs::path("R", "mod-load_occurrence_data.R"), envir = globalenv())

p_module <- profvis::profvis({
  for (i in seq_len(5)) {
    shiny::testServer(
      ingest_occurrence_data_server,
      args = list(reopen_trigger = shiny::reactive(0L)),
      {
        session$setInputs(
          occurrence_data_uploaded = list(
            name = "bral.xlsx",
            datapath = occurrence_data,
            size = file.info(occurrence_data)$size,
            type = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
          )
        )
        stopifnot(isTRUE(session$returned$ready()))

        session$setInputs(
          occurrence_data_uploaded = list(
            name = "test_file.xlsx",
            datapath = missing_data,
            size = file.info(missing_data)$size,
            type = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
          )
        )
        stopifnot(isFALSE(session$returned$ready()))

        session$setInputs(close_modal = 1)
      }
    )
  }
})
save_prof(p_module, "04-upload-module-server")

message("Component profiling complete. See ", normalizePath(results_dir))
