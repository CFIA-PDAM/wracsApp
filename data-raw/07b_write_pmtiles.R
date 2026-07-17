write_pmtiles <- function(mb_path, pm_path) {
  pmtiles::pm_convert(mb_path, pm_path, force = TRUE)
  pm_path
}
