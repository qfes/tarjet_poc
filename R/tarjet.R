tar_julia <- function(name, command, format = "fst", ...) {

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
      quote(make_target_julia),
      command_expr,
      as.name(file_target_name),
      format,
      function_args
    ))
  command_target <- targets::tar_target_raw(
    name = deparse(substitute(name)),
    command = command,
    storage = "none", # julia to write target output
    retrieval = "none", # manually load dependencies from cache in julia,
    format = format,
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

make_target_julia <- function(command, command_source_path, output_format, ...) {
  
  fn_args <- eval(substitute(alist(...)))

  cached_target_fn_args <-
    Filter(is_cached_target, fn_args)

  cached_target_names <-
    as.character(cached_target_fn_args)

  target_arguments <-
    cached_target_fn_args |>
    lapply(tar_path_raw) |>
    setNames(cached_target_names)

  output_path <- targets::tar_path()

  command_text <- deparse(substitute(command))

  result <- JuliaCall::julia_call(
    "julia_make_target",
    command_text,
    output_path,
    output_format,
    target_arguments)
  result

}

in_wd <- function(x) fs::path_common(c(x, fs::path_wd())) == fs::path_wd()

is_cached_target <- function(name) {
  eval(
    bquote(file.exists(targets::tar_path(.(name))))
  )
}

tar_path_raw <- function(name) {
  eval(
    bquote(targets::tar_path(.(as.symbol(name))))
  )
}

tar_interoperable <- function(expr) {
  # wrap return value in serialiser
  ## serialise_interoperable() S3 method?
  # set format parquet
}

function() {
  JuliaCall::julia_assign("command_text", command_text)
  JuliaCall::julia_assign("output_path", tar_path(fastest_2_Julia))
  JuliaCall::julia_assign("output_format", output_format)
  JuliaCall::julia_assign("target_arguments", target_arguments)
  JuliaCall::julia_command("target_arguments")
}