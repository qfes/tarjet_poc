import DataStructures
import FstFileFormat

function julia_make_target(command_text, output_path, output_format, target_arguments)
	command_text = "fastest_2_Julia_fn(travel_times, 2, a_target)"
	output_path = "_targets/objects/fastest_2_Julia"
	output_format = "parquet"
	target_arguments = DataStructures.OrderedDict{Symbol, Any}(
          :travel_times => "_targets/objects/travel_times",
	  :a_target => "_targets/objects/travel_times"
	)

	objects = map(function (p)
             (p.first, FstFileFormat.read(p.second))
             end, 
	     collect(target_arguments))


	true
end