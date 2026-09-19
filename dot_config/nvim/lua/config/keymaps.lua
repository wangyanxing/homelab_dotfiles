-- Custom keymaps, loaded on top of LazyVim's defaults.
-- (LazyVim auto-loads lua/config/keymaps.lua)
-- Keep this small and avoid clobbering LazyVim's built-in mappings.

local map = vim.keymap.set

-- Center screen after half-page jumps and search results.
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev search result (centered)" })

-- Keep visual selection when re-indenting.
map("v", "<", "<gv", { desc = "Indent left, keep selection" })
map("v", ">", ">gv", { desc = "Indent right, keep selection" })

-- Move selected lines up/down (visual mode).
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Paste over selection without yanking the replaced text.
map("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

-- Yank to system clipboard.
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
