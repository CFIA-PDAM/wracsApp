ingest_occurrence_data_server <- function(id, reopen_trigger = NULL) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns

    state <- shiny::reactiveValues(
      occurrence_data = NULL,
      upload_ready = FALSE,
      upload_failed = FALSE,
      failed_file_name = NULL,
      missing_columns_list = NULL,
    )

    expected_names <- occurrence_data_column_names

    output$alert_area <- shiny::renderUI({
      if (state$upload_failed) {
        shiny::div(
          class = "alert alert-danger",
          shiny::icon("circle-exclamation"),
          shiny::HTML(paste0(
            " Upload failed. Your file (<b>",
            htmltools::htmlEscape(state$failed_file_name),
            "</b>) is missing the following required column(s):"
          )),
          shiny::tags$ul(lapply(state$missing_columns_list, shiny::tags$li)),
          "Please correct the file and upload it again."
        )
      } else if (state$upload_ready) {
        shiny::div(
          class = "alert alert-success",
          shiny::icon("circle-check"),
          shiny::HTML(paste0(
            " Upload complete. Your occurrence data (<b>",
            htmltools::htmlEscape(input$occurrence_data_uploaded$name),
            "</b>) has been processed."
          ))
        )
      }
    })

    output$footer_area <- shiny::renderUI({
      shiny::tagList(
        shiny::actionButton(
          ns("close_modal"),
          "Continue",
          disabled = !state$upload_ready
        ),
        shiny::modalButton("Close")
      )
    })

    build_modal <- function() {
      shiny::modalDialog(
        htmltools::HTML(paste(
          "To begin, please upload an Excel (.xlsx) file containing the occurrence
      data for your focal species exactly as extracted from the Global
      Biodiversity Information Facility.",
          "<br><br>",
          "Once the file has been uploaded, please click continue to proceed. Note
      that you will be unable to use the tool until an occurrence data file has
      been uploaded.",
          "<br><br>",
          "Note that uploading a new file will reset the application to its initial
      state and any progress with the old file will be lost.",
          "<br><br>"
        )),
        shiny::fileInput(
          ns("occurrence_data_uploaded"),
          NULL,
          accept = ".xlsx"
        ),
        shiny::uiOutput(ns("alert_area")),
        title = "Geospatial Weed Risk Assessment Tool",
        footer = shiny::uiOutput(ns("footer_area"), inline = TRUE),
        size = "l"
      )
    }

    show_modal <- function() {
      shiny::showModal(build_modal())
    }

    shiny::observeEvent(
      TRUE,
      {
        show_modal()
      },
      once = TRUE,
      ignoreNULL = FALSE
    )

    if (!is.null(reopen_trigger)) {
      shiny::observeEvent(
        reopen_trigger(),
        {
          show_modal()
        },
        ignoreInit = TRUE,
        ignoreNULL = TRUE
      )
    }

    shiny::observeEvent(input$occurrence_data_uploaded, {
      shiny::req(input$occurrence_data_uploaded)

      df <- readxl::read_excel(
        input$occurrence_data_uploaded$datapath,
        n_max = 1
      )
      missing_columns <- setdiff(expected_names, names(df))

      if (!vctrs::vec_is_empty(missing_columns)) {
        state$failed_file_name <- input$occurrence_data_uploaded$name
        state$missing_columns_list <- missing_columns
        state$upload_failed <- TRUE
        state$upload_ready <- FALSE
        state$occurrence_data <- NULL
        return()
      }

      shiny::showNotification(
        ui = "Adding QC codes and covariate data",
        duration = NULL,
        id = "notification_processing_data",
        type = "message"
      )

      state$upload_failed <- FALSE
      state$occurrence_data <- df
      state$upload_ready <- TRUE

      shiny::removeNotification(id = "notification_processing_data")
    })

    shiny::observeEvent(input$close_modal, {
      shiny::removeModal()
    })

    list(
      data = shiny::reactive({
        state$occurrence_data
      }),
      ready = shiny::reactive({
        state$upload_ready
      }),
      show = show_modal
    )
  })
}
