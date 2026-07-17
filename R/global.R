basis_of_records <- c(
  "PRESERVED_SPECIMEN",
  "HUMAN_OBSERVATION",
  "MATERIAL_CITATION",
  "OBSERVATION",
  "OCCURRENCE",
  "LIVING_SPECIMEN",
  "MATERIAL_SAMPLE",
  "MACHINE_OBSERVATION"
)

occurrence_data_column_names <- c(
  "acceptedScientificName",
  "datasetName",
  "habitat",
  "municipality",
  "basisOfRecord",
  "decimalLatitude",
  "identifiedBy",
  "organismRemarks",
  "countryCode",
  "decimalLongitude",
  "institutionCode",
  "occurrenceRemarks",
  "county",
  "elevation",
  "issue",
  "scientificName",
  "cultivarEpithet",
  "gbifID",
  "locality",
  "stateProvince",
  "year"
)

qc_codes <- c(
  "NoXYold",
  "CurrReg",
  "00XY",
  "XYnoYR",
  "XYold",
  "Cult",
  "iNat",
  "OK"
)

qc_code_descriptions <- c(
  "No lat/long coordinates, and year is missing or less than 1980",
  "No lat/long coordinates and year is > 1979 (good regional records)",
  "Coordinates are 0,0",
  "Data has coordinates, but there is no year",
  "Data has coordinates, but record is old (<1980)",
  "The habitat or locality field suggests the plant may have been cultivated",
  "Data has coordinates and originated from iNaturalist",
  "None of the above criteria were met"
)

qc_code_ref_table <- tibble::tibble(
  qc_code = qc_codes,
  qc_code_description = qc_code_descriptions
) |>
  dplyr::filter(qc_code != "OK")
