reproject_raster <- function(rgb_raster, reprojected_filename) {
  temp_file <- fs::path_temp(fs::path_file(reprojected_filename))

  # Reproject to Web Mercator (EPSG:3857)
  sf::gdal_utils(
    util = "warp",
    source = terra::sources(rgb_raster),
    destination = temp_file,
    options = c(
      "-t_srs",
      "EPSG:3857",
      "-ot",
      "Byte",
      "-dstnodata",
      "255",
      "-r",
      "near",
      "-overwrite"
    )
  )

  terra::rast(temp_file)
}
