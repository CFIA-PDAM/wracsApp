write_tile_tree <- function(mb_path, tile_dir) {
  con <- DBI::dbConnect(
    drv = RSQLite::SQLite(),
    dbname = mb_path
  )
  on.exit(DBI::dbDisconnect(conn = con), add = TRUE)

  tiles_df <- DBI::dbGetQuery(
    conn = con,
    statement = "SELECT zoom_level, tile_column, tile_row, tile_data FROM tiles"
  )

  for (i in base::seq_len(base::nrow(tiles_df))) {
    z <- tiles_df$zoom_level[i]
    x <- tiles_df$tile_column[i]
    y_tms <- tiles_df$tile_row[i]

    # Invert Y-axis: TMS → XYZ (Leaflet) convention
    y_xyz <- (2^z - 1) - y_tms

    target_folder <- fs::path(tile_dir, z, x)
    base::dir.create(target_folder, recursive = TRUE, showWarnings = FALSE)

    file_path <- fs::path(target_folder, base::paste0(y_xyz, ".png"))
    base::writeBin(
      object = base::unlist(tiles_df$tile_data[[i]]),
      con = file_path
    )
  }

  tile_dir
}
