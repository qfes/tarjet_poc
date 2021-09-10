tar_julia <- function(name, command, ...) {

  command_expr <- substitute(command)
  if (!inherits(command_expr, "call")) stop("I only accept Julia function calls for now.")
  function_name <- deparse(command_expr[[1]])
  function_args <- as.list(command_expr)[-1]
  methods_result <-
    JuliaCall::julia_eval(glue::glue("methods({function_name}) |> (x -> map(string, x))"))
  if (length(methods_result) == 0) {
    stop(
      "Could not find Julia function matching your expression:",
      deparse(command_expr)
    )
  }
  function_paths <-
    parse_julia_paths(methods_result) |>
    unique()

  local_function_path <-
    Filter(in_wd, function_paths)

  if (length(local_function_path) != 1) {
    stop(
      "Julia function matched in more than one local source file:",
      paste(local_function_path)
    )
  }
  file_target_name <- glue::glue("{function_name}_source")
  file_target <- targets::tar_target_raw(
    name = file_target_name,
    command = local_function_path,
    format = "file"
  )
  command <-
    as.call(c(
      quote(julia_eval_source),
      function_name,
      as.name(file_target_name),
      function_args
    ))
  command_target <- targets::tar_target_raw(
    name = glue::glue("{function_name}_exec"),
    command = command,
    ...
  )

  list(
    file_target,
    command_target
  )
}

load_julia_sources <- function() {
  julia_files <-
    list.files(
      julia_source_path(),
      full.names = TRUE
    )
  JuliaCall::julia_call("include.", julia_files)
}

`%|s|%` <- function(a, b) {
  if (!(rlang::is_scalar_character(a) && nzchar(a))) b else a
}

julia_source_path <- function() Sys.getenv("JULIA_TARGET_SOURCES") %|s|% "Julia"

parse_julia_paths <- function(methods_result) {
  file_path <- gregexec("at\\s(?<path>.*)(?=:[0-9]+)", methods_result, perl = TRUE)
  regmatches(methods_result, file_path) |>
  lapply(function(x) x["path", ]) |>
  unlist() |>
  unname()
}

julia_eval_source <- function(fn, path, ...) {
  JuliaCall::julia_call(fn, ...)
}

in_wd <- function(x) fs::path_common(c(x, fs::path_wd())) == fs::path_wd()
