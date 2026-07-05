-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Visual modeで Cmd+c を押した時に切り取り(Change)ではなくコピー(Yank)にする
-- ※GUI (Neovide等) や Cmdを透過するターミナル用
vim.keymap.set({ "v", "x" }, "<D-c>", '"+y', { desc = "Copy to system clipboard" })
