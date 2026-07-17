ui <- bslib::page_navbar(
  id = "tabs",
  title = htmltools::HTML(
    "Geospatial Weed Risk",
    "<br>",
    "Assessment Tool"
  ),

  header = shiny::tagList(
    shiny::tags$head(
      shiny::tags$link(
        rel = "stylesheet",
        href = "www/styles.css"
      ),
    ),
    shinyjs::useShinyjs(),
    shiny::useBusyIndicators()
  ),

  sidebar = bslib::sidebar(
    width = 300,
    resizable = FALSE,
    shiny::actionButton(
      "reopen_upload_modal",
      "Upload Occurrence Data",
      icon = fontawesome::fa("upload"),
      class = "btn-primary",
      style = "width: 100%;"
    ),
    bslib::accordion(
      id = "sidebar_settings",
      bslib::accordion_panel(
        "Occurrence Data",
        icon = fontawesome::fa("leaf"),
        shiny::checkboxGroupInput(
          inputId = "quality_control_filter",
          label = shiny::span(
            "Quality Control Filters",
            bslib::tooltip(
              bsicons::bs_icon("info-circle"),
              "Flag records to withhold from assessment by clicking one or more of the quality control codes below. Flagging records is delayed by at least 5 seconds to avoid overly eager execution.",
              placement = "top"
            )
          ),
          choiceNames = purrr::pmap(
            qc_code_ref_table,
            ~ bslib::tooltip(.x, .y)
          ),
          choiceValues = base::as.list(qc_code_ref_table$qc_code),
          selected = NULL
        ),
        shiny::checkboxGroupInput(
          inputId = "basis_of_record_filter",
          label = shiny::span(
            "Basis of Record Filters",
            bslib::tooltip(
              bsicons::bs_icon("info-circle"),
              "Flag records to withhold from assessment by clicking one or more of the basis of records' below. Flagging records is delayed by at least 5 seconds to avoid overly eager execution.",
              placement = "top"
            )
          ),
          choices = base::as.list(basis_of_records),
          selected = NULL
        )
      ),
      bslib::accordion_panel(
        "Map Settings",
        icon = fontawesome::fa("map"),
        shiny::textInput("marker_id", "Enter Marker ID to Zoom to:", ""),
        bslib::input_task_button(
          "restore_clicked_ids",
          "Click to include all occurrence records that were excluded by manual clicking of points"
        )
      ),
      bslib::accordion_panel(
        "Plot Settings",
        icon = fontawesome::fa("chart-simple"),
        shiny::radioButtons(
          "plot_occurrence_data",
          "Add occurrence data to plot?",
          choiceNames = c("Yes", "No"),
          choiceValues = c(TRUE, FALSE),
          selected = FALSE
        ),
        shiny::downloadButton(
          "export_analysis_files",
          "Click to export analysis output files"
        )
      )
    )
  ),

  bslib::nav_panel(
    "1 Occurrence Data",
    reactable::reactableOutput("occurrence_table")
  ),
  bslib::nav_panel(
    "2 Data Summary",
    reactable::reactableOutput("sum_table")
  ),
  bslib::nav_panel(
    "3 Map",
    leaflet::leafletOutput("leaflet_map")
  ),
  bslib::nav_panel(
    "4 Koppen-Geiger Table",
    "Be sure to navigate to the Map Worksheet tab before the Suitability Maps tab to incorporate any changes to `climate_type_suitable`",
    reactable::reactableOutput("kg_table")
  ),
  bslib::nav_panel(
    "5 Plant Hardiness Table",
    "Be sure to navigate to the Map Worksheet tab before the Suitability Maps tab to incorporate any changes to `climate_type_suitable`",
    reactable::reactableOutput("ph_table")
  ),
  bslib::nav_panel(
    "6 Precipitation Bands Table",
    "Be sure to navigate to the Map Worksheet tab before the Suitability Maps tab to incorporate any changes to `climate_type_suitable`",
    reactable::reactableOutput("pb_table")
  ),
  bslib::nav_panel(
    "7 Map Worksheet",
    "Koppen-Geiger Summary",
    reactable::reactableOutput("kg_suitability_summary"),
    "Plant Hardiness Summary",
    reactable::reactableOutput("ph_suitability_summary"),
    "Precipitation Bands Summary",
    reactable::reactableOutput("pb_suitability_summary")
  ),
  bslib::nav_panel(
    "8 Suitability Maps",
    shiny::imageOutput("plot_can_usa", width = 1400, height = 800)
  ),
)
