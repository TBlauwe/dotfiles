return {
  name = "CMake Configure",
  desc = "Configure CMake Project with dev preset",
  builder = function(params)
    return {
      name = "CMake Configure",
      cmd = {'cmake'},
      args = {"--preset", "dev"},
    }
  end,
  condition = {
    filetype = {"c", "cpp", "cmake"}
  }
}

