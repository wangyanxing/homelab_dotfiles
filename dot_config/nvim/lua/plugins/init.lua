-- Your custom plugins & overrides live here (files in lua/plugins/*.lua).
-- Language support (LSP + formatting + completion) is enabled via LazyVim
-- "extras" in lazyvim.json: python, json, yaml, typescript, clangd(c/c++),
-- docker, markdown, prettier. This file adds treesitter parsers for the
-- config-file / misc languages those extras don't already pull in.
return {
  -- Colorscheme
  { "folke/tokyonight.nvim", opts = { style = "night" } },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "tokyonight" },
  },

  -- Treesitter parsers (syntax highlight / indent) for common languages.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash", "lua", "vim", "vimdoc",
        "python", "json", "jsonc", "yaml", "toml", "ini",
        "javascript", "typescript", "tsx",
        "c", "cpp", "cmake", "make",
        "dockerfile", "markdown", "markdown_inline",
        "gitignore", "gitcommit", "diff", "html", "css",
      },
    },
  },
}
