write_ocean_mask <- function(source_raster, country_polygons) {
  countries_vect <- terra::vect(country_polygons)

  if (!terra::same.crs(countries_vect, source_raster)) {
    countries_vect <- terra::project(countries_vect, terra::crs(source_raster))
  }

  # Set everything outside land polygons to NA across all bands
  terra::mask(source_raster, countries_vect)
}
