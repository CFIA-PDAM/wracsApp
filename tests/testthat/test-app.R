app <- shinytest2::AppDriver$new(
  testthat::test_path("../.."),
  height = 855,
  width = 1235,
  load_timeout = 120000,
  name = "app"
)
withr::defer(app$stop(), envir = testthat::teardown_env())

# ---- 1. initial load -------------------------------------------------------

testthat::test_that("app loads and immediately shows the upload modal", {
  app$wait_for_idle()

  app$wait_for_js("document.querySelector('.modal') !== null")
  app$wait_for_js(
    "document.querySelector('#upload-occurrence_data_uploaded') !== null"
  )
  app$expect_values()
})

# ---- 2. occurrence data upload flow ----------------------------------------

testthat::test_that("uploading an invalid occurrence file results in an error message", {
  app$upload_file(`upload-occurrence_data_uploaded` = "test_file.xlsx")
  app$wait_for_idle()

  app$expect_values()
})

testthat::test_that("reopening the modal and clearing the file input resets the upload state", {
  app$click("reopen_upload_modal")
  app$set_inputs(`upload-occurrence_data_uploaded` = character(0))
  app$wait_for_idle()

  app$expect_values()
})

testthat::test_that("uploading a valid file replaces the previous upload and updates the occurrence table", {
  app$upload_file(`upload-occurrence_data_uploaded` = "psja.xlsx")
  app$wait_for_idle()

  app$expect_values()
})

testthat::test_that("closing the modal via the footer button hides it", {
  app$click("upload-close_modal")
  app$wait_for_idle()

  app$expect_values()
})

testthat::test_that("reopening then closing the modal without changing the file is a no-op", {
  app$click("reopen_upload_modal")
  app$click("upload-close_modal")
  app$set_inputs(`upload-occurrence_data_uploaded` = character(0))
  app$wait_for_idle()
  app$expect_values()
  app$wait_for_idle()

  app$expect_values()
})

testthat::test_that("reopening the modal results in a file-upload-ready state", {
  app$click("reopen_upload_modal")
  app$wait_for_idle()

  app$expect_values()
})

testthat::test_that("uploading a second valid file replaces the previous upload", {
  app$upload_file(`upload-occurrence_data_uploaded` = "bral.xlsx")
  app$wait_for_idle()

  app$expect_values()
})

testthat::test_that("closing the modal via the footer button hides it and shows the updated occurrence table", {
  app$click("upload-close_modal")
  app$wait_for_idle()

  app$expect_values()
})

# ---- 3. primary tab navigation ---------------------------------------------

testthat::test_that("the Data Summary tab can be selected", {
  app$set_inputs(tabs = "2 Data Summary")
  app$wait_for_idle()

  testthat::expect_equal(app$get_value(input = "tabs"), "2 Data Summary")
  app$expect_values()
})

testthat::test_that("the Koppen-Geiger Table tab renders", {
  app$set_inputs(tabs = "4 Koppen-Geiger Table")
  app$wait_for_idle()

  app$expect_values()
})

testthat::test_that("the Plant Hardiness Table tab renders", {
  app$set_inputs(tabs = "5 Plant Hardiness Table")
  app$wait_for_idle()

  app$expect_values()
})

testthat::test_that("the Precipitation Bands Table tab renders", {
  app$set_inputs(tabs = "6 Precipitation Bands Table")
  app$wait_for_idle()

  app$expect_values()
})

testthat::test_that("the Map Worksheet tab renders its three summary tables", {
  app$set_inputs(tabs = "7 Map Worksheet")
  app$wait_for_idle()

  app$expect_values()
})

testthat::test_that("the Suitability Maps tab renders the exported plot image", {
  app$set_inputs(tabs = "8 Suitability Maps")
  app$wait_for_idle()

  app$expect_values()
})

# ---- 4. sidebar: occurrence data filters -----------------------------------

testthat::test_that("quality control and basis-of-record filters can be combined", {
  app$set_inputs(quality_control_filter = "NoXYold")
  app$set_inputs(quality_control_filter = c("NoXYold", "XYnoYR"))
  app$set_inputs(basis_of_record_filter = "MATERIAL_CITATION")
  app$wait_for_idle()

  app$expect_values()
})

# ---- 5. sidebar: accordion panel switching --------------------------------

testthat::test_that("opening the Map Settings panel and restoring excluded points works", {
  app$set_inputs(sidebar_settings = character(0))
  app$set_inputs(sidebar_settings = c("Map Settings"))
  app$set_inputs(restore_clicked_ids = c(1, 1))
  app$wait_for_idle()

  app$expect_values()
})

testthat::test_that("opening the Plot Settings panel and toggling the occurrence overlay works", {
  app$set_inputs(sidebar_settings = character(0))
  app$set_inputs(sidebar_settings = c("Plot Settings"))
  app$set_inputs(plot_occurrence_data = "TRUE")
  app$wait_for_idle()

  app$expect_values()
})

# ---- 6. export -------------------------------------------------------------

testthat::test_that("the analysis output files can be exported", {
  app$expect_download("export_analysis_files")
})

# ---- 7. map: layer/group toggles -------------------------------------------

testthat::test_that("the Map tab can be selected", {
  app$set_inputs(tabs = "3 Map")
  app$wait_for_idle()

  testthat::expect_equal(app$get_value(input = "tabs"), "3 Map")
  app$expect_values(input = c("leaflet_map_zoom", "leaflet_map_groups"))
})

testthat::test_that("toggling the Precipitation Bands and Points overlay groups updates the map", {
  app$set_inputs(
    leaflet_map_groups = "Precipitation Bands",
    allow_no_input_binding_ = TRUE
  )
  app$wait_for_idle()
  app$expect_values(input = c("leaflet_map_zoom", "leaflet_map_groups"))

  app$set_inputs(
    leaflet_map_groups = c("Precipitation Bands", "Points"),
    allow_no_input_binding_ = TRUE
  )
  app$wait_for_idle()
  app$expect_values(input = c("leaflet_map_zoom", "leaflet_map_groups"))
})

# ---- 8. map: viewport interactions (bounds/centre/zoom) --------------------

testthat::test_that("panning and zooming the map updates the tracked viewport", {
  app$set_inputs(
    leaflet_map_bounds = base::list(
      north = 59.977005492196,
      east = 39.0234375,
      south = 11.9533493936434,
      west = -38.935546875
    ),
    allow_no_input_binding_ = TRUE
  )
  app$set_inputs(leaflet_map_zoom = 4, allow_no_input_binding_ = TRUE)
  app$wait_for_idle()
  app$expect_values(input = c("leaflet_map_zoom", "leaflet_map_groups"))

  app$set_inputs(
    leaflet_map_bounds = base::list(
      north = 70.4367988185464,
      east = 90,
      south = -25.1651733686639,
      west = -65.91796875
    ),
    allow_no_input_binding_ = TRUE
  )
  app$set_inputs(
    leaflet_map_center = base::list(
      lng = 11.9656476024679,
      lat = 35.021553085928
    ),
    allow_no_input_binding_ = TRUE
  )
  app$set_inputs(leaflet_map_zoom = 3, allow_no_input_binding_ = TRUE)
  app$wait_for_idle()
  app$expect_values(input = c("leaflet_map_zoom", "leaflet_map_groups"))

  app$set_inputs(
    leaflet_map_bounds = base::list(
      north = 69.0245597462886,
      east = 96.8906271457672,
      south = -28.7984736467112,
      west = -59.0273416042328
    ),
    allow_no_input_binding_ = TRUE
  )
  app$set_inputs(
    leaflet_map_center = base::list(
      lng = 18.9316427707672,
      lat = 31.5485783628205
    ),
    allow_no_input_binding_ = TRUE
  )
  app$wait_for_idle()
  app$expect_values(input = c("leaflet_map_zoom", "leaflet_map_groups"))
})

# ---- 9. map: and marker hover/click/mouseout events ----------------------------

testthat::test_that("hovering, clicking, and un-hovering a marker registers the correct events", {
  app$set_inputs(
    leaflet_map_marker_mouseover = base::list(
      id = "b",
      .nonce = 0.233138558795347,
      group = "Points",
      lat = 30,
      lng = 20
    ),
    allow_no_input_binding_ = TRUE
  )
  app$wait_for_idle()
  app$expect_values(
    input = c(
      "leaflet_map_zoom",
      "leaflet_map_groups",
      "leaflet_map_marker_mouseover"
    )
  )

  app$set_inputs(
    leaflet_map_marker_click = base::list(
      id = "b",
      .nonce = 0.747359637167649,
      group = "Points",
      lat = 30,
      lng = 20
    ),
    allow_no_input_binding_ = TRUE
  )
  app$set_inputs(
    leaflet_map_marker_mouseout = base::list(
      id = "b",
      .nonce = 0.53220830030355,
      group = "Points",
      lat = 30,
      lon = 20
    ),
    allow_no_input_binding_ = TRUE
  )
  app$wait_for_idle()
  app$expect_values(
    input = c(
      "leaflet_map_zoom",
      "leaflet_map_groups",
      "leaflet_map_marker_mouseover",
      "leaflet_map_marker_click",
      "leaflet_map_marker_mouseout"
    )
  )
})

# ---- 10. map: base layer switching + reference overlays ---------------------

testthat::test_that("adding the Equator overlay to the Precipitation Bands base layer works", {
  app$set_inputs(
    leaflet_map_groups = c("Precipitation Bands", "Equator", "Points"),
    allow_no_input_binding_ = TRUE
  )
  app$wait_for_idle()
  app$expect_values(
    input = c(
      "leaflet_map_zoom",
      "leaflet_map_groups",
      "leaflet_map_marker_mouseover",
      "leaflet_map_marker_click",
      "leaflet_map_marker_mouseout"
    )
  )
})

testthat::test_that("adding the Tropic of Cancer overlay works alongside the Equator", {
  app$set_inputs(
    leaflet_map_groups = c(
      "Precipitation Bands",
      "Equator",
      "Tropic of Cancer",
      "Points"
    ),
    allow_no_input_binding_ = TRUE
  )
  app$wait_for_idle()
  app$expect_values(
    input = c(
      "leaflet_map_zoom",
      "leaflet_map_groups",
      "leaflet_map_marker_mouseover",
      "leaflet_map_marker_click",
      "leaflet_map_marker_mouseout"
    )
  )
})

testthat::test_that("switching the base layer to Plant Hardiness Zones keeps overlays intact", {
  app$set_inputs(
    leaflet_map_groups = c(
      "Plant Hardiness Zones",
      "Equator",
      "Tropic of Cancer",
      "Points"
    ),
    allow_no_input_binding_ = TRUE
  )
  app$wait_for_idle()
  app$expect_values(
    input = c(
      "leaflet_map_zoom",
      "leaflet_map_groups",
      "leaflet_map_marker_mouseover",
      "leaflet_map_marker_click",
      "leaflet_map_marker_mouseout"
    )
  )
})

testthat::test_that("switching the base layer to Köppen-Geiger Levels keeps overlays intact", {
  app$set_inputs(
    leaflet_map_groups = c(
      "Köppen-Geiger Levels",
      "Equator",
      "Tropic of Cancer",
      "Points"
    ),
    allow_no_input_binding_ = TRUE
  )
  app$wait_for_idle()
  app$expect_values(
    input = c(
      "leaflet_map_zoom",
      "leaflet_map_groups",
      "leaflet_map_marker_mouseover",
      "leaflet_map_marker_click",
      "leaflet_map_marker_mouseout"
    )
  )
})
