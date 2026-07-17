write_mbtiles <- function(reprojected_raster, mb_path) {
  # Package baseline native zoom level (7)
  sf::gdal_utils(
    util = "translate",
    source = terra::sources(reprojected_raster),
    destination = mb_path,
    options = c(
      "-of",
      "MBTILES",
      "-co",
      "TILE_FORMAT=PNG",
      "-co",
      "RESAMPLING=NEAREST"
    )
  )

  # Build overview pyramid: zoom levels 0–6
  sf::gdal_addo(
    file = mb_path,
    overviews = c(2, 4, 8, 16, 32, 64, 128),
    method = "NEAREST",
    clean = FALSE
  )

  mb_path
}
