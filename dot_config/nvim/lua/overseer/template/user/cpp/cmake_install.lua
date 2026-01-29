return {
  name = "CMake Install",
  desc = "Install CMake Project",
  builder = function(params)
    return {
      name = "CMake Install",
      cmd = {'cmake'},
      args = {"--install", "./build/"},
    }
  end,
  condition = {
    filetype = {"c", "cpp", "cmake"}
  }
}
