write_rgb_tif <- function(cog, band_idx, rgb_filename) {
  temp_file <- fs::path_temp(fs::path_file(rgb_filename))

  gdalraster::dem_proc(
    mode = "color-relief",
    srcfile = terra::sources(cog),
    dstfile = temp_file,
    color_file = write_colour_file(band_idx),
    mode_options = c("-alpha", "-exact_color_entry")
  )

  terra::rast(temp_file)
}
