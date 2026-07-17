write_cog <- function(source_raster, band_idx) {
  terra::as.int(terra::round(source_raster[[band_idx]]))
}
