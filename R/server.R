server <- function(input, output, session) {
  # ---- Upload modal ----
  shinyjs::useShinyjs()

  upload <- ingest_occurrence_data_server(
    "upload",
    reopen_trigger = shiny::reactive(input$reopen_upload_modal)
  )

  occurrence_data <- shiny::reactiveVal()
  shiny::observe({
    shiny::req(upload$data())
    occurrence_data(upload$data())
  })

  # ---- Placeholders ----
  dummy_df <- data.frame(
    message = "Placeholder",
    value = 1
  )

  # ---- 1. Occurrence Table -------------------------------------------------------

  output$occurrence_table <- reactable::renderReactable({
    reactable::reactable(dummy_df)
  })

  shiny::observe({
    shiny::req(occurrence_data())

    output$occurrence_table <- reactable::renderReactable({
      reactable::reactable(
        data = occurrence_data(),
        striped = TRUE,
        filterable = TRUE,
        resizable = TRUE
      )
    })
  })

  # Update the occurrence table as the occurrence data is filtered
  shiny::observe({
    reactable::updateReactable("occurrence_table", occurrence_data())
  })

  # ---- 2. Summary Table -------------------------------------------------------

  output$sum_table <- reactable::renderReactable({
    reactable::reactable(dummy_df)
  })

  # ---- 4. KG Table -------------------------------------------------------

  output$kg_table <- reactable::renderReactable({
    reactable::reactable(dummy_df)
  })

  # ---- 5. PH Table -------------------------------------------------------

  output$ph_table <- reactable::renderReactable({
    reactable::reactable(dummy_df)
  })

  # ---- 6. PB Table -------------------------------------------------------

  output$pb_table <- reactable::renderReactable({
    reactable::reactable(dummy_df)
  })

  # ---- 7. Suitability Summaries -------------------------------------------------------

  output$kg_suitability_summary <- reactable::renderReactable({
    reactable::reactable(dummy_df)
  })

  output$ph_suitability_summary <- reactable::renderReactable({
    reactable::reactable(dummy_df)
  })

  output$pb_suitability_summary <- reactable::renderReactable({
    reactable::reactable(dummy_df)
  })

  shiny::exportTestValues(
    map_n_markers = 0,
    map_initialized = TRUE
  )

  # ---- 8. Plots -------------------------------------------------------

  output$plot_can_usa <- shiny::renderImage(
    {
      tf <- file.path(tempdir(), "plot_can_usa.png")

      grDevices::png(tf, width = 800, height = 600)
      graphics::plot.new()
      graphics::text(0.5, 0.5, "Placeholder suitability map")
      grDevices::dev.off()

      list(
        src = tf,
        contentType = "image/png",
        width = 800,
        height = 600,
        alt = "Suitability map for Canada and USA"
      )
    },
    deleteFile = FALSE
  )

  output$export_analysis_files <- shiny::downloadHandler(
    filename = function() {
      "placeholder.txt"
    },
    content = function(file) {
      writeLines("Placeholder export", file)
    }
  )

  shiny::outputOptions(
    output,
    "export_analysis_files",
    suspendWhenHidden = FALSE
  )

  # ---- 3. Map -------------------------------------------------------

  output$leaflet_map <- leaflet::renderLeaflet({
    pb_pal <- create_leaflet_palette(pal_pb_hex)
    phz_pal <- create_leaflet_palette(pal_phz_hex)
    kgc_pal <- create_leaflet_palette(pal_kgc_hex)
    opacity <- 0.7
    legend_position <- "bottomleft"
    tile_options <- leaflet::tileOptions(
      noWrap = TRUE,
      opacity = opacity,
      tms = FALSE,
      maxNativeZoom = 7
    )

    purrr::iwalk(
      base::list(
        "equator" = 0,
        "tropic_of_cancer" = 24.436,
        "tropic_of_capricorn" = -24.436
      ),
      \(value, name) {
        polyline <- sf::st_sfc(
          sf::st_linestring(
            matrix(c(-180, value, 180, value), ncol = 2, byrow = TRUE)
          ),
          crs = 4326
        )

        assign(name, polyline, envir = .GlobalEnv)
      }
    )

    leaflet::leaflet(
      options = leaflet::leafletOptions(minZoom = 1.5, zoomSnap = 0.5)
    ) |>
      leaflet::addTiles(options = leaflet::tileOptions(noWrap = TRUE)) |>
      leaflet::setMaxBounds(-180, -90, 180, 90) |>
      leaflet::setView(lng = 0, lat = 40, zoom = 3) |>
      leaflet::addTiles(
        urlTemplate = "/tiles/pb/{z}/{x}/{y}.png",
        group = "Precipitation Bands",
        options = tile_options
      ) |>
      leaflet::addTiles(
        urlTemplate = "/tiles/phz/{z}/{x}/{y}.png",
        group = "Plant Hardiness Zones",
        options = tile_options
      ) |>
      leaflet::addTiles(
        urlTemplate = "/tiles/kgc/{z}/{x}/{y}.png",
        group = "Köppen-Geiger Levels",
        options = tile_options
      ) |>
      leaflet::addLegend(
        position = legend_position,
        pal = pb_pal,
        values = c(1:11),
        title = "Precipitation Band",
        group = "Precipitation Bands",
        opacity = opacity
      ) |>
      leaflet::addLegend(
        position = legend_position,
        pal = phz_pal,
        values = c(1:28),
        title = "Plant Hardiness Zone",
        group = "Plant Hardiness Zones",
        opacity = opacity
      ) |>
      leaflet::addLegend(
        position = legend_position,
        pal = kgc_pal,
        values = c(1:30),
        title = "Köppen-Geiger Level",
        group = "Köppen-Geiger Levels",
        opacity = opacity
      ) |>
      leaflet::addPolylines(
        data = equator,
        group = "Equator",
        color = "#808080",
        weight = 1,
        opacity = 1
      ) |>
      leaflet::addPolylines(
        data = tropic_of_cancer,
        group = "Tropic of Cancer",
        color = "#808080",
        weight = 1,
        opacity = 1
      ) |>
      leaflet::addPolylines(
        data = tropic_of_capricorn,
        group = "Tropic of Capricorn",
        color = "#808080",
        weight = 1,
        opacity = 1
      ) |>
      leaflet::addLayersControl(
        baseGroups = c(
          "Precipitation Bands",
          "Plant Hardiness Zones",
          "Köppen-Geiger Levels"
        ),
        overlayGroups = c(
          "Equator",
          "Tropic of Cancer",
          "Tropic of Capricorn"
        ),
        options = leaflet::layersControlOptions(collapsed = FALSE)
      ) |>
      leaflet::hideGroup(c(
        "Equator",
        "Tropic of Cancer",
        "Tropic of Capricorn"
      )) |>
      leaflet::addScaleBar(
        position = "bottomright",
        options = leaflet::scaleBarOptions(
          metric = TRUE,
          imperial = TRUE,
          maxWidth = 200
        )
      ) |>
      htmlwidgets::onRender(
        "
      function(el, x) {
        var map = this;
        var legendTitles = {
          'Precipitation Bands': 'Precipitation Band',
          'Plant Hardiness Zones': 'Plant Hardiness Zone',
          'Köppen-Geiger Levels': 'Köppen-Geiger Level'
        };
        function showOnlyLegend(activeGroup) {
          document.querySelectorAll('.leaflet-control.info.legend').forEach(function(legend) {
            var title = legend.querySelector('.leaflet-legend-title, h4, strong');
            if (!title) return;
            legend.style.display = (legendTitles[activeGroup] === title.textContent.trim()) ? 'block' : 'none';
          });
        }
        setTimeout(function() { showOnlyLegend('Precipitation Bands'); }, 0);
        map.on('baselayerchange', function(e) { showOnlyLegend(e.name); });
      }
    "
      )
  })

  shiny::observe({
    req(input$leaflet_map_zoom)

    leaflet::leafletProxy("leaflet_map") |>
      leaflet::clearGroup("Points") |>
      leaflet::addCircleMarkers(
        lng = c(0, 20, -40),
        lat = c(0, 30, -20),
        radius = 6,
        fillOpacity = 1,
        color = "red",
        layerId = c("a", "b", "c"),
        popup = glue::glue(
          "{climateSuitabilityWRA:::.packageName}",
          "Country: ",
          "Ocurrence records no coordinates: ",
          .sep = "<br>"
        ),
        group = "Points"
      )
  })

  selected_marker <- shiny::reactiveVal()

  shiny::observeEvent(input$leaflet_map_marker_click, {
    selected_marker(input$leaflet_map_marker_click$id)

    message("Clicked marker: ", selected_marker())
  })
}
