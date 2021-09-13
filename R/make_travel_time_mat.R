#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param n_incidents
#' @param n_locations
#' @param n_stations
#' @return
#' @author Miles McBain
#' @export
make_travel_time_mat <- function(n_incidents, n_locations, n_stations) {

  times <- sample.int(20 * 60, n_incidents * (n_locations + n_stations), replace = TRUE)
  dim(times) <- c(n_stations + n_locations, n_incidents)

}
