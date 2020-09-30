#' Title
#'
#' @param point_data
#' @param higher_geo_lay
#' @param unique_id_code
#' @param class_col
#' @param crs
#' @param total_points
#'
#' @return
#' @export
#'
#' @examples
point_class <- function(point_data,
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

    return(points_count)
  }
  else if (total_points == FALSE) {
    # do the same including the categories
    points_count <- dplyr::count(dplyr::as_tibble(points_in_grids),
                                 !!as.name(unique_id_code),
                                 !!as.name(class_col))

    names(points_count)[3] <- "NoPoints"
    points_count_wide <- tidyr::spread(points_count, 2, 3)

    results <- list("points_long" = points_count,
                    "points_wide" = points_count_wide)

    return(results)
  }


}
