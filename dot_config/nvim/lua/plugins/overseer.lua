return {
  'stevearc/overseer.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  
  opts = {
    templates = {
      "builtin",
      "user.cpp",
    },
  },

  keys = {
    -- General --
    { "<leader>ot", "<cmd>OverseerToggle<cr>", desc = "Overseer: Toggle" },
    { "<leader>oq", "<cmd>OverseerQuickAction<cr>10<cr>", desc = "Overseer: Re-run" },
    { "<leader>or", "<cmd>OverseerRun<cr>", desc = "Overseer: Run command" },
    { "<leader>oo", "<cmd>OverseerOpen<cr>", desc = "Overseer: Open" },
    -- C++ / CMake --
  },
}
