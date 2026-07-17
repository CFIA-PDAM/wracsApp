fetch_country_polygons <- function() {
  df <- rnaturalearth::ne_countries(scale = 10, returnclass = "sf")

  dplyr::summarize(
    df,
    lvl1 = iso_a2,
    lvl2 = dplyr::if_else(iso_a2 == "PR", "US", iso_a2),
    .by = geometry
  )
}
