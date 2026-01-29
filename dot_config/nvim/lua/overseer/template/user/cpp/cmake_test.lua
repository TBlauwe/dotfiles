return {
  name = "CMake Test",
  desc = "Test CMake Project with dev preset using CTest",
  builder = function(params)
    return {
      name = "CMake Test",
      cmd = {'ctest'},
      args = {"--preset", "dev"},
    }
  end,
  condition = {
    filetype = {"c", "cpp", "cmake"}
  },
}
