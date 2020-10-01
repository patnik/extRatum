#' Areal data calculation
#'
#' Calculates the area covered by
#'
#' @param polygon_layer multipologon object of class \code{sf}, \code{sfc} or \code{sfg}
#'
#' @param higher_geo_lay multipologon object of class \code{sf}, \code{sfc} or \code{sfg}
#'
#' @param unique_id_code a string, indicating the unique ID column of \code{higher_geo_lay} in which
#' we want to summarise the data
#'
#' @param crs coordinate reference system: integer with the EPSG code, or character with proj4string
#'
#' @return a \code{tibble} data frame object
#'
#' @examples
#'
#'
#' @export

areal_calc <- function(polygon_layer,
                       higher_geo_lay,
                       unique_id_code,
                       crs) {


  # we need a crs that is planar
  crs = crs
  # make sure that all layers have consistent CRS- in this case is WGS84
  polygon_layer <- sf::st_transform(polygon_layer, crs)
  higher_geo_lay <- sf::st_transform(higher_geo_lay, crs)

  #### 1st step
  # calculate total area of grids
  higher_geo_lay$tot_area_sqkm <-
    sf::st_area(higher_geo_lay$geometry) / 1000000
  # convert area of grids to numeric too
  higher_geo_lay$tot_area_sqkm <-
    as.numeric(higher_geo_lay$tot_area_sqkm)

  # assume that the attribute is constant throughout the geometry
  sf::st_agr(polygon_layer) = "constant"
  sf::st_agr(higher_geo_lay) = "constant"


  #run the intersect function, converting the output to a tibble in the process
  int <- dplyr::as_tibble(sf::st_intersection(polygon_layer, higher_geo_lay))

  int$area_sqkm <- sf::st_area(int$geometry) / 1000000

  # convert area to numeric
  int$area_sqkm <- as.numeric(int$area_sqkm)

  # remove polygons that are outside the grid boundaries to avoid getting errors
  int <- int %>%
    tidyr::drop_na(!!as.name(unique_id_code))

  CoverByGeo <- int %>%
    dplyr::group_by(!!as.name(unique_id_code)) %>% # '!!' this evaluates if it is true, when it is '!' evaluates if it is false
    dplyr::summarise(AreaCovered = sum(area_sqkm), .groups = 'drop_last')



  results <- CoverByGeo
  return(results)

}
