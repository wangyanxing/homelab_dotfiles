-- Your custom plugins & overrides live here (files in lua/plugins/*.lua).
-- This starter keeps things minimal. A few sensible, common plugins:
return {
  -- Colorscheme
  { "folke/tokyonight.nvim", opts = { style = "night" } },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "tokyonight" },
  },

  -- Example: enable a treesitter language (uncomment/add as needed)
  -- {
  --   "nvim-treesitter/nvim-treesitter",
  --   opts = { ensure_installed = { "bash", "lua", "python", "json", "yaml" } },
  -- },
}
