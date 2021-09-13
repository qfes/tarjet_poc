## Load your packages, e.g. library(targets).
source("./packages.R")

## Load your Julia packages
JuliaCall::julia_call("include", "packages.jl")

## Load your R files
lapply(list.files("./R", full.names = TRUE), source)

## Load your Julia files
load_julia_sources()

## tar_plan supports drake-style targets and also tar_target()
tar_plan(
  # target = function_to_make(arg), ## drake style
  n_incidents = 10000,
  n_locations = 5000,
  n_stations = 10,
  tar_target(
    travel_times,
    make_travel_time_mat(
      n_incidents,
      n_locations,
      n_stations
    ),
    format = "fst"
  ),
  fastest_2_R = fastest_2_R_fn(
    travel_times
  ),
  tar_target(
    # prototype for tar_interoperable
    a_target,
    10,
    format = "fst"
  ),
  tar_julia(
    fastest_2_Julia,
    fastest_2_Julia_fn(travel_times, 2, a_target)
  )
)
