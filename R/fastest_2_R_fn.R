#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param travel_time_mat
#' @return
#' @author Miles McBain
#' @export
fastest_2_R_fn <- function(travel_times) {

    apply(
      travel_times,
      2,
      function(times) {
        result <- sort.int(times, index.return = TRUE)
        result$ix[1:2]
      }
    )


}
