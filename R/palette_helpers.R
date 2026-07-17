# ── Named band palettes ──

# Helper: convert a named rgb-vector palette to a colour-table data frame
palette_to_coltab <- function(pal_vec) {
  rgb_mat <- grDevices::col2rgb(pal_vec) # 3 × n matrix
  data.frame(
    value = as.integer(names(pal_vec)),
    r = as.integer(rgb_mat["red", ]),
    g = as.integer(rgb_mat["green", ]),
    b = as.integer(rgb_mat["blue", ]),
    alpha = 255L
  )
}

create_leaflet_palette <- function(pal) {
  leaflet::colorFactor(
    palette = pal,
    levels = names(pal),
    na.color = "#00000000"
  )
}

# Layer 1 — pb
pal_pb_hex <- base::c(
  `1` = grDevices::rgb(249, 240, 219, maxColorValue = 255),
  `2` = grDevices::rgb(249, 219, 168, maxColorValue = 255),
  `3` = grDevices::rgb(219, 240, 198, maxColorValue = 255),
  `4` = grDevices::rgb(168, 240, 168, maxColorValue = 255),
  `5` = grDevices::rgb(219, 198, 240, maxColorValue = 255),
  `6` = grDevices::rgb(240, 168, 249, maxColorValue = 255),
  `7` = grDevices::rgb(240, 97, 168, maxColorValue = 255),
  `8` = grDevices::rgb(240, 32, 32, maxColorValue = 255),
  `9` = grDevices::rgb(168, 240, 240, maxColorValue = 255),
  `10` = grDevices::rgb(32, 168, 240, maxColorValue = 255),
  `11` = grDevices::rgb(32, 65, 240, maxColorValue = 255)
)

# Layer 3 — phz
pal_phz_hex <- base::c(
  `1` = grDevices::rgb(229, 230, 230, maxColorValue = 255),
  `2` = grDevices::rgb(197, 198, 198, maxColorValue = 255),
  `3` = grDevices::rgb(168, 169, 169, maxColorValue = 255),
  `4` = grDevices::rgb(197, 163, 201, maxColorValue = 255),
  `5` = grDevices::rgb(165, 127, 169, maxColorValue = 255),
  `6` = grDevices::rgb(201, 126, 201, maxColorValue = 255),
  `7` = grDevices::rgb(128, 128, 201, maxColorValue = 255),
  `8` = grDevices::rgb(98, 97, 201, maxColorValue = 255),
  `9` = grDevices::rgb(159, 193, 228, maxColorValue = 255),
  `10` = grDevices::rgb(126, 162, 227, maxColorValue = 255),
  `11` = grDevices::rgb(128, 201, 127, maxColorValue = 255),
  `12` = grDevices::rgb(97, 169, 97, maxColorValue = 255),
  `13` = grDevices::rgb(169, 201, 126, maxColorValue = 255),
  `14` = grDevices::rgb(198, 228, 127, maxColorValue = 255),
  `15` = grDevices::rgb(228, 229, 126, maxColorValue = 255),
  `16` = grDevices::rgb(228, 229, 97, maxColorValue = 255),
  `17` = grDevices::rgb(228, 229, 66, maxColorValue = 255),
  `18` = grDevices::rgb(228, 200, 66, maxColorValue = 255),
  `19` = grDevices::rgb(228, 169, 66, maxColorValue = 255),
  `20` = grDevices::rgb(197, 128, 66, maxColorValue = 255),
  `21` = grDevices::rgb(166, 97, 66, maxColorValue = 255),
  `22` = grDevices::rgb(198, 66, 66, maxColorValue = 255),
  `23` = grDevices::rgb(167, 33, 33, maxColorValue = 255),
  `24` = grDevices::rgb(99, 34, 34, maxColorValue = 255),
  `25` = grDevices::rgb(198, 198, 198, maxColorValue = 255),
  `26` = grDevices::rgb(167, 167, 167, maxColorValue = 255),
  `27` = grDevices::rgb(228, 97, 168, maxColorValue = 255),
  `28` = grDevices::rgb(228, 66, 198, maxColorValue = 255)
)

# Layer 5 — kgc
# Colours are pulled from https://github.com/hylken/Koppen-Geiger_maps/blob/V3/assets/legend.txt
pal_kgc_hex <- base::c(
  `1` = grDevices::rgb(0, 0, 255, maxColorValue = 255),
  `2` = grDevices::rgb(0, 120, 255, maxColorValue = 255),
  `3` = grDevices::rgb(70, 170, 250, maxColorValue = 255),
  `4` = grDevices::rgb(255, 0, 0, maxColorValue = 255),
  `5` = grDevices::rgb(255, 150, 150, maxColorValue = 255),
  `6` = grDevices::rgb(245, 165, 0, maxColorValue = 255),
  `7` = grDevices::rgb(255, 220, 100, maxColorValue = 255),
  `8` = grDevices::rgb(255, 255, 0, maxColorValue = 255),
  `9` = grDevices::rgb(200, 200, 0, maxColorValue = 255),
  `10` = grDevices::rgb(150, 150, 0, maxColorValue = 255),
  `11` = grDevices::rgb(150, 255, 150, maxColorValue = 255),
  `12` = grDevices::rgb(100, 200, 100, maxColorValue = 255),
  `13` = grDevices::rgb(50, 150, 50, maxColorValue = 255),
  `14` = grDevices::rgb(200, 255, 80, maxColorValue = 255),
  `15` = grDevices::rgb(100, 255, 80, maxColorValue = 255),
  `16` = grDevices::rgb(50, 200, 0, maxColorValue = 255),
  `17` = grDevices::rgb(255, 0, 255, maxColorValue = 255),
  `18` = grDevices::rgb(200, 0, 200, maxColorValue = 255),
  `19` = grDevices::rgb(150, 50, 150, maxColorValue = 255),
  `20` = grDevices::rgb(150, 100, 150, maxColorValue = 255),
  `21` = grDevices::rgb(170, 175, 255, maxColorValue = 255),
  `22` = grDevices::rgb(90, 120, 220, maxColorValue = 255),
  `23` = grDevices::rgb(75, 80, 180, maxColorValue = 255),
  `24` = grDevices::rgb(50, 0, 135, maxColorValue = 255),
  `25` = grDevices::rgb(0, 255, 255, maxColorValue = 255),
  `26` = grDevices::rgb(55, 200, 255, maxColorValue = 255),
  `27` = grDevices::rgb(0, 125, 125, maxColorValue = 255),
  `28` = grDevices::rgb(0, 70, 95, maxColorValue = 255),
  `29` = grDevices::rgb(178, 178, 178, maxColorValue = 255),
  `30` = grDevices::rgb(102, 102, 102, maxColorValue = 255)
)

# Map band index → pre-built colour-table data frame
band_palettes <- base::list(
  `1` = palette_to_coltab(pal_pb_hex),
  `3` = palette_to_coltab(pal_phz_hex),
  `5` = palette_to_coltab(pal_kgc_hex)
)

write_colour_file <- function(band_idx) {
  key <- as.character(band_idx)
  
  if (is.null(band_palettes[[key]])) {
    cli::cli_abort("No colour palette available for band {key}")
  }
  
  ct <- band_palettes[[key]]
  
  colour_file <- fs::path_temp(fs::path_file(glue::glue("band_{key}_palette.txt")))
  
  utils::write.table(
    ct[, c("value", "r", "g", "b", "alpha")],
    colour_file,
    row.names = FALSE,
    col.names = FALSE,
    quote = FALSE
  )
  
  cat("nv 0 0 0 0\n", file = colour_file, append = TRUE)

  colour_file
}
