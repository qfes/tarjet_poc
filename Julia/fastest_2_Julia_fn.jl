function fastest_2_Julia_fn(travel_times)
     sorted = mapslices(sortperm, travel_times, dims=1)
     sorted[1:2,:]
end