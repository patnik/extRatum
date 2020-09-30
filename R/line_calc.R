#' Title
#'
#' @param line_layer
#' @param higher_geo_lay
#' @param unique_id_code
#' @param crs
#'
#' @return
#' @export
#'
#' @examples
line_calc <- function(line_layer,
                      higher_geo_lay,
                      unique_id_code,
                      crs) {

  crs = crs
  # make sure that all layers have consistent CRS- in this case is WGS84
  line_layer <- sf::st_transform(line_layer, crs)
  higher_geo_lay <- sf::st_transform(higher_geo_lay, crs)

  # assume that the attribute is constant throughout the geometry
  st_agr(line_layer) = "constant"
  st_agr(higher_geo_lay) = "constant"

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
    dplyr::summarise(Length = sum(foot_len), .groups = 'drop_last')



  results <- LengthByGeo
  return(results)

}

