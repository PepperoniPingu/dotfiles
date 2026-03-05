-- 1. BOOTSTRAP LAZY.NVIM (The Plugin Manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=v11.17.5",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 2. SETUP PLUGINS
require("lazy").setup({
  -- The theme you wanted
  { "rebelot/kanagawa.nvim", priority = 1000 },
  
  -- Add other plugins here in the future
})

-- 3. LOAD THE THEME
vim.cmd("colorscheme kanagawa")

-- 4. BASIC SETTINGS
vim.opt.number = true         -- Show line numbers
vim.opt.relativenumber = true -- Great for jumping around
vim.opt.mouse = 'a'           -- Let's you use the mouse if you get stuck
