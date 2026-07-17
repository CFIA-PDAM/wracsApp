pkgload::load_all()

fs::dir_create("inst", "extdata", "tiles")

shiny::addResourcePath(
  prefix = "tiles",
  directoryPath = system.file("extdata", "tiles", package = "botanyGeospatialWRA")
)

shiny::addResourcePath(
  prefix = "www",
  directoryPath = system.file("app", "www", package = "botanyGeospatialWRA")
)

shiny::shinyApp(ui, server)
