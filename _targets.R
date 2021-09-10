## Load your packages, e.g. library(targets).
source("./packages.R")

## Load your Julia libraries
JuliaCall::julia_call("include", "julia_libraries.jl")

## Load your R files
lapply(list.files("./R", full.names = TRUE), source)

## Load your Julia files
load_julia_sources()

## tar_plan supports drake-style targets and also tar_target()
tar_plan(
  # target = function_to_make(arg), ## drake style
  n_incidents = 10000,
  n_locations = 1000,
  n_stations = 10,
  travel_times = make_travel_time_mat(
    n_incidents,
    n_locations,
    n_stations
  ),
  fastest_2_R = fastest_2_R_fn(
    travel_times
  ),
  tar_julia(
    fastest_2_Julia,
    fastest_2_Julia_fn(travel_times)
  )
)
