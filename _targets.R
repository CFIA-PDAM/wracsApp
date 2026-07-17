targets::tar_option_set(
  memory = "transient",
  garbage_collection = 2
)

targets::tar_source(c("R/palette_helpers.R", "data-raw"))

# ── Constants ──────────────────────────────────────────────────────────────────
periods <- c("2011.2040", "2041.2070")
scenarios <- c("ssp370", "ssp585")
base_dir <- fs::path(
  Sys.getenv("LAKEHOUSE_DIR"),
  "Files",
  "extract_climate_data"
)
source_tif <- fs::path(base_dir, "raster.ensemble.2041.2070.ssp370.tif")

var_values <- tibble::tibble(
  var = c("pb", "phz", "kgc"),
  band_idx = c(1L, 3L, 5L)
)

# ── Assemble pipeline ──────────────────────────────────────────────────────────
base::list(
  geotargets::tar_terra_rast(
    name = source_raster,
    command = terra::rast(source_tif),
    description = "Source raster with climate indicators"
  ),

  targets::tar_target(
    name = country_polygons,
    command = fetch_country_polygons(),
    description = "Country polygons for ocean data masking"
  ),

  geotargets::tar_terra_rast(
    name = source_masked,
    command = write_ocean_mask(
      source_raster = source_raster,
      country_polygons = country_polygons
    ),
    description = "Source raster with ocean data masked out"
  ),

  tarchetypes::tar_map(
    values = var_values,
    names = "var",

    geotargets::tar_terra_rast(
      name = cog,
      command = write_cog(
        source_raster = source_masked,
        band_idx = band_idx
      ),
      filetype = "COG",
      datatype = "INT1U",
      gdal = c(
        "COMPRESS=DEFLATE",
        "OVERVIEW_RESAMPLING=NEAREST",
        "BLOCKSIZE=512"
      ),
      description = "A single Cloud-optimised GeoTIFF per climate indicator"
    ),

    geotargets::tar_terra_rast(
      name = rgb_raster,
      command = write_rgb_tif(
        cog = cog,
        band_idx = band_idx,
        rgb_filename = paste0("rgb_", var, "_mode.tif")
      ),
      description = "A single RGB GeoTIFF per climate indicator"
    ),

    geotargets::tar_terra_rast(
      name = reprojected,
      command = reproject_raster(
        rgb_raster = rgb_raster,
        reprojected_filename = paste0("temp_byte_mercator_", var, ".tif")
      ),
      description = "A single RGB GeoTIFF reprojected to Web Mercator (EPSG:3857) per climate indicator"
    ),

    targets::tar_target(
      name = mbtiles,
      command = write_mbtiles(
        reprojected_raster = reprojected,
        mb_path = fs::path("data", paste0(var, "_all_zoom.mbtiles"))
      ),
      format = "file",
      description = "A single Mapbox tiles file per climate indicator"
    ),

    targets::tar_target(
      name = tile_tree,
      command = write_tile_tree(
        mb_path = mbtiles,
        tile_dir = fs::path("inst", "extdata", "tiles", var)
      ),
      description = "A single Z/X/Y tile tree per climate indicator"
    ),

    targets::tar_target(
      name = pmtiles,
      command = write_pmtiles(
        mb_path = mbtiles,
        pm_path = fs::path_ext_set(
          fs::path("data", paste0(var, "_all_zoom.mbtiles")),
          "pmtiles"
        )
      ),
      format = "file",
      description = "A single Protomaps tiles file per climate indicator"
    )
  )
)
