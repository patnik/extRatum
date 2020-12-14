#' Point data calculation
#'
#' Calculates the number of a multipoint object within a set of polygons, as well as the
#' the ratio between the number of points and the total area of a higher geography polygon.
#' If there is a clasification of the points, this function is able to return the same summary
#' measures for each class.
#'
#' @param point_data multipoint object of class \code{sf}, \code{sfc} or \code{sfg}.
#'
#' @param higher_geo_lay multipologon object of class \code{sf}, \code{sfc} or \code{sfg}.
#'
#' @param unique_id_code a string; indicating the unique ID column of \code{higher_geo_lay}, in which
#' we want to summarise the data.
#'
#' @param class_col a string; indicating the column name of \code{point_data} that contains
#' information on the classification of points. It is used when \code{total_points = FALSE}.
#'
#' @param crs coordinate reference system: integer with the EPSG code, or character with proj4string.
#'
#' @param total_points logical; do we want to measure the total number of points? if set to \code{FALSE} it returns the
#' functio results by each point class; if missing, defaults to \code{TRUE}.
#'
#' @return if \code{total_points = TRUE}:
#' A \code{tibble} data frame objects containing three columns:
#' the \code{unique_id_code} of \code{higher_geo_lay}, the total area of each polygon
#' in \code{higher_geo_lay} (Tot_area_sqkm), the total number of point features \code{point_data} (NoPoints),
#' and the ratio between the total number of point features \code{point_data} and the the total area of
#' \code{higher_geo_lay} polygon (Ratio).
#'
#' if \code{total_points = FALSE}:
#' A list of three \code{tibble} data frame objects.
#'
#' - The object \code{PointsLong} contains three columns:
#' the \code{unique_id_code} of \code{higher_geo_lay}, the \code{class_col} of \code{point_data},
#' the number of point features \code{point_data} by class (NoPoints), the total area of each polygon
#' in \code{higher_geo_lay} (Tot_area_sqkm) and the ratio between the number of point features by class \code{point_data}
#' and the the total area of \code{higher_geo_lay} polygon (Ratio).
#'
#' - The object \code{PointsCountWide}:
#' Returns the point counts of \code{PointsLong} by \code{unique_id_code} and \code{class_col} in a wide format.
#'
#' - The object \code{PointsRatioWide}:
#' Returns the ratio of \code{PointsLong} by \code{unique_id_code} and \code{class_col} in a wide format.
#'
#'
#' @examples
#' # Run the point_calc() function using the toy datasets provided by the package.
#' # The datasets are georeferenced in wgs84. However, we need a planar system to measure areas.
#' # In this case, the points and polygons are in the UK so we use the British National Grid.
#'
#' # This example will return the total points count and ratio
#' outcome1 <- point_calc(
#'  point_data = points,
#'  higher_geo_lay = pol_large,
#'  unique_id_code = "large_pol_",
#'  crs = "epsg:27700",
#'  total_points = TRUE)
#'
#'  # print the outcome
#'  outcome1
#'
#'
#'  #' # This example will return the points count and ratio by class
#' outcome2 <- point_calc(
#'  point_data = points,
#'  higher_geo_lay = pol_large,
#'  unique_id_code = "large_pol_",
#'  class_col = "class_name",
#'  crs = "epsg:27700",
#'  total_points = FALSE)
#'
#'  # print the outcome in a long format
#'  outcome2$PointsLong
#'
#'  # print the point count by class in a wide format
#'  outcome2$PointsCountWide
#'
#'  # print the point ratio by class in a wide format
#'  outcome2$PointsRatioWide
#'
#'
#' @importFrom dplyr "%>%"
#'
#' @export

point_calc <- function(point_data,
                        higher_geo_lay,
                        unique_id_code,
                        class_col,
                        crs,
                        total_points = TRUE) {
  # assume that the attribute is constant throughout the geometry
  sf::st_agr(point_data) = "constant"
  sf::st_agr(higher_geo_lay) = "constant"

  # we need a crs that is planar
  crs = crs
  # make sure that all layers have consistent CRS- in this case is WGS84
  point_data <- sf::st_transform(point_data, crs)
  higher_geo_lay <- sf::st_transform(higher_geo_lay, crs)

  # calculate total area of the higher geography layer
  higher_geo_lay$Tot_area_sqkm <-
    sf::st_area(higher_geo_lay$geometry) / 1000000
  # convert area of the higher geography layer to numeric too
  higher_geo_lay$Tot_area_sqkm <-
    as.numeric(higher_geo_lay$Tot_area_sqkm)

  # find points within polygons
  points_in_grids <-
    sf::st_join(point_data, higher_geo_lay, join = sf::st_within)

  # remove points that are outside the grid boundaries to avoid getting errors
  points_in_grids <- points_in_grids %>%
    tidyr::drop_na(!!as.name(unique_id_code))

  #### 2nd step
  if (total_points == TRUE) {
    # to count the number of points by grid
    points_count <- dplyr::count(dplyr::as_tibble(points_in_grids),!!as.name(unique_id_code))
    names(points_count)[2] <- "NoPoints"

    # to calculate the ratio of points by the total area of the higher geography layer
    combined_data <- dplyr::left_join(points_count, higher_geo_lay, by = unique_id_code)
    combined_data$Ratio <- combined_data$NoPoints / combined_data$Tot_area_sqkm

    result1 <- combined_data[,c(unique_id_code, "Tot_area_sqkm", "NoPoints", "Ratio")]

    return(result1)
  }
  else if (total_points == FALSE) {
    # do the same including the categories
    points_count <- dplyr::count(dplyr::as_tibble(points_in_grids),
                                 !!as.name(unique_id_code),
                                 !!as.name(class_col))

    names(points_count)[3] <- "NoPoints"
    points_count_wide <- tidyr::spread(points_count, 2, 3)

    # to calculate the ratio of points by the total area of the higher geography layer

    # treat the dataset as dataframe
    sf::st_geometry(higher_geo_lay) <- NULL

    combined_data <- dplyr::left_join(points_count, higher_geo_lay[,c(unique_id_code, "Tot_area_sqkm")], by = unique_id_code)

    points_ratio <- combined_data %>%
      dplyr::mutate(Ratio = NoPoints  / Tot_area_sqkm)

    points_ratio <- points_ratio[,c(unique_id_code, "Tot_area_sqkm", class_col, "NoPoints", "Ratio")]

    # create a subset with the columns needed
    points_ratio_subset <- points_ratio[, c(1,3,5)]

    points_ratio_wide <- tidyr::spread(points_ratio_subset, 2, 3)


    results2 <- list("PointsLong" = points_ratio,
                     "PointsCountWide" = points_count_wide,
                     "PointsRatioWide" = points_ratio_wide)

    return(results2)
  }


}
