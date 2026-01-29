return {
  name = "CMake clean",
  desc = "Clean output directory",
  builder = function(params)
    return {
      name = "Clean output directory",
      cmd = {'cmake'},
      args = {"-E", "remove_directory", "./out/", "./build/"},
    }
  end,
  condition = {
    filetype = {"c", "cpp", "cmake"}
  }
}
