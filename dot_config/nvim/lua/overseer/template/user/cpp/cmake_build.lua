return {
  name = "CMake Build",
  desc = "Build CMake Project with dev preset",
  builder = function(params)
    return {
      name = "CMake Build",
      cmd = {'cmake'},
      args = {"--build", "--preset", "dev"},
    }
  end,
  condition = {
    filetype = {"c", "cpp", "cmake"}
  },
}

