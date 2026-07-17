library(shinytest2)

testthat::test_that("app walkthrough", {
  app <- AppDriver$new(
    test_path("../.."),
    height = 855,
    width = 1235,
    load_timeout = 60000
  )
  app$wait_for_idle()
  app$expect_values(screenshot_args = FALSE)

  app$upload_file(`upload-occurrence_data_uploaded` = "test_file.xlsx")
  app$wait_for_idle()
  app$expect_values(screenshot_args = FALSE)
  # Close modal
  app$wait_for_idle()
  app$expect_values(screenshot_args = FALSE)

  app$click("reopen_upload_modal")
  app$set_inputs(`upload-occurrence_data_uploaded` = character(0))
  app$wait_for_idle()
  app$expect_values(screenshot_args = FALSE)

  app$upload_file(`upload-occurrence_data_uploaded` = "bral.xlsx")
  app$wait_for_idle()
  app$expect_values(screenshot_args = FALSE)

  app$click("upload-close_modal")
  app$wait_for_idle()
  app$expect_values(screenshot_args = FALSE)

  app$click("reopen_upload_modal")
  app$click("upload-close_modal")
  app$set_inputs(`upload-occurrence_data_uploaded` = character(0))
  app$wait_for_idle()
  app$expect_values(screenshot_args = FALSE)
  # Close modal
  app$wait_for_idle()
  app$expect_values(screenshot_args = FALSE)

  app$set_inputs(tabs = "2 Data Summary")
  app$wait_for_idle()
  app$expect_values(screenshot_args = FALSE)

  app$set_inputs(tabs = "3 Map")
  app$wait_for_idle()
  app$expect_values(screenshot_args = FALSE)

  app$set_inputs(
    leaflet_map_groups = "Precipitation Bands",
    allow_no_input_binding_ = TRUE
  )
  app$set_inputs(
    leaflet_map_groups = c("Precipitation Bands", "Points"),
    allow_no_input_binding_ = TRUE
  )
  app$wait_for_idle()
  app$expect_values()
  app$set_inputs(
    leaflet_map_bounds = c(
      55.0280221129925,
      53.0859375,
      1.84538398857319,
      -24.873046875
    ),
    allow_no_input_binding_ = TRUE
  )
  app$set_inputs(
    leaflet_map_center = c(14.0880775079307, 32.1507596753828),
    allow_no_input_binding_ = TRUE
  )
  app$set_inputs(leaflet_map_zoom = 4, allow_no_input_binding_ = TRUE)
  app$set_inputs(
    leaflet_map_bounds = c(
      41.1455697310095,
      40.60546875,
      12.9403221283846,
      1.6259765625
    ),
    allow_no_input_binding_ = TRUE
  )
  app$set_inputs(
    leaflet_map_center = c(21.1065387539653, 27.9426239872105),
    allow_no_input_binding_ = TRUE
  )
  app$set_inputs(leaflet_map_zoom = 5, allow_no_input_binding_ = TRUE)
  app$wait_for_idle()
  app$expect_values()
  app$set_inputs(
    leaflet_map_bounds = c(
      34.6621281354234,
      36.8789041042328,
      4.81949994524189,
      -2.10058808326721
    ),
    allow_no_input_binding_ = TRUE
  )
  app$set_inputs(
    leaflet_map_center = c(17.3891580104828, 20.459953064659),
    allow_no_input_binding_ = TRUE
  )
  app$wait_for_idle()
  app$expect_values()
  app$set_inputs(
    leaflet_map_marker_mouseover = list(
      id = "b",
      .nonce = 0.329135257036314,
      group = "Points",
      lat = 30,
      lng = 20
    ),
    allow_no_input_binding_ = TRUE
  )
  app$set_inputs(
    leaflet_map_marker_click = list(
      id = "b",
      .nonce = 0.210888440987886,
      group = "Points",
      lat = 30,
      lng = 20
    ),
    allow_no_input_binding_ = TRUE
  )
  app$set_inputs(
    leaflet_map_marker_mouseout = list(
      id = "b",
      .nonce = 0.76118303596281,
      group = "Points",
      lat = 30,
      lng = 20
    ),
    allow_no_input_binding_ = TRUE
  )
  app$wait_for_idle()
  app$expect_values()
  app$set_inputs(
    leaflet_map_groups = c("Precipitation Bands", "Equator", "Points"),
    allow_no_input_binding_ = TRUE
  )
  app$wait_for_idle()
  app$expect_values()
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
  app$expect_values()
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
  app$expect_values()
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
  app$expect_values()

  app$set_inputs(tabs = "4 Koppen-Geiger Table")
  app$wait_for_idle()
  app$expect_values(screenshot_args = FALSE)

  app$set_inputs(tabs = "5 Plant Hardiness Table")
  app$wait_for_idle()
  app$expect_values(screenshot_args = FALSE)

  app$set_inputs(tabs = "6 Precipitation Bands Table")
  app$wait_for_idle()
  app$expect_values(screenshot_args = FALSE)

  app$set_inputs(tabs = "7 Map Worksheet")
  app$wait_for_idle()
  app$expect_values(screenshot_args = FALSE)

  app$set_inputs(tabs = "8 Suitability Maps")
  app$wait_for_idle()
  app$expect_values(screenshot_args = FALSE)

  app$set_inputs(quality_control_filter = "NoXYold")
  app$set_inputs(quality_control_filter = c("NoXYold", "XYnoYR"))
  app$set_inputs(basis_of_record_filter = "MATERIAL_CITATION")
  app$wait_for_idle()
  app$expect_values(screenshot_args = FALSE)

  app$set_inputs(sidebar_settings = character(0))
  app$set_inputs(sidebar_settings = c("Map Settings"))
  app$set_inputs(restore_clicked_ids = c(1, 1))
  app$wait_for_idle()
  app$expect_values(screenshot_args = FALSE)

  app$set_inputs(sidebar_settings = character(0))
  app$set_inputs(sidebar_settings = c("Plot Settings"))
  app$set_inputs(plot_occurrence_data = "TRUE")
  app$wait_for_idle()
  app$expect_values(screenshot_args = FALSE)
  app$expect_download("export_analysis_files")
})
