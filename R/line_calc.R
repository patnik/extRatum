#' Line data calculation
#'
#' Calculates the total length of a multilinestring object within a set of polygons, as well as the
#' the ratio between the total length and the total area of a higher geography polygon.
#'
#' @param line_layer multilinestring object of class \code{sf}, \code{sfc} or \code{sfg}.
#'
#' @param higher_geo_lay multipologon object of class \code{sf}, \code{sfc} or \code{sfg}.
#'
#' @param unique_id_code a string; indicating the unique ID column of \code{higher_geo_lay}, in which
#' we want to summarise the data.
#'
#' @param crs coordinate reference system: integer with the EPSG code, or character with proj4string.
#'
#' @return a \code{tibble} data frame object containing three columns:
#' the \code{unique_id_code} of \code{higher_geo_lay}, the total area of each polygon
#' in \code{higher_geo_lay} (Tot_area_sqkm), the total length of \code{line_layer} features (TotalLength),
#' and the ratio between the total length of \code{line_layer} and the the total area of
#' \code{higher_geo_lay} polygon (Ratio).
#'
#' @examples
#' # Run the line_calc() function using the toy datasets provided by the package.
#' # The datasets are georeferenced in wgs84.
#' # However, we need a planar system to measure line lengths and areas.
#' # In this case, the lines and polygons are in the UK so we use the British National Grid.
#' outcome <- line_calc(
#'  line_layer = lines,
#'  higher_geo_lay = pol_large,
#'  unique_id_code = "large_pol_",
#'  crs = "epsg:27700")
#'
#'  # print the outcome
#'  outcome
#'
#' @importFrom dplyr "%>%"
#'
#' @export
line_calc <- function(line_layer,
                      higher_geo_lay,
                      unique_id_code,
                      crs) {

  crs = crs
  # make sure that all layers have consistent CRS- in this case is WGS84
  line_layer <- sf::st_transform(line_layer, crs)
  higher_geo_lay <- sf::st_transform(higher_geo_lay, crs)

  # calculate total area of the higher geography layer
  higher_geo_lay$Tot_area_sqkm <-
    sf::st_area(higher_geo_lay$geometry) / 1000000
  # convert area of the higher geography layer to numeric too
  higher_geo_lay$Tot_area_sqkm <-
    as.numeric(higher_geo_lay$Tot_area_sqkm)

  # assume that the attribute is constant throughout the geometry
  sf::st_agr(line_layer) = "constant"
  sf::st_agr(higher_geo_lay) = "constant"

  #run the intersect function, converting the output to a tibble in the process
  int <- dplyr::as_tibble(sf::st_intersection(line_layer, higher_geo_lay))

  # calculate the length of each line in metres
  int$foot_len <- sf::st_length(int$geometry)

  # convert area to numeric
  int$foot_len <- as.numeric(int$foot_len)

  # remove polygons that are outside the grid boundaries to avoid getting errors
  int <- int %>%
    tidyr::drop_na(!!as.name(unique_id_code))

  LengthByGeo <- int %>%
    dplyr::group_by(!!as.name(unique_id_code)) %>% # '!!' this evaluates if it is true, when it is '!' evaluates if it is false
    dplyr::summarise(TotalLength = sum(foot_len), .groups = 'drop_last')

  # to calculate the ratio of length by the total area of the higher geography layer
  combined_data <- dplyr::left_join(LengthByGeo, higher_geo_lay, by = unique_id_code)
  combined_data$Ratio <- combined_data$TotalLength / combined_data$Tot_area_sqkm



  results <- combined_data[,c(unique_id_code, "Tot_area_sqkm", "TotalLength", "Ratio")]

  return(results)

}

