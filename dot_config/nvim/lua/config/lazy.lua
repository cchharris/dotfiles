-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.env["CODECOMPANION_TOKEN_PATH"] = vim.fn.expand("~/.config")

local is_windows = vim.fn.has("win32") == 1

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  -- On non-Windows, nix provides plugins via packpath — preserve it so
  -- nix-managed plugins (e.g. nvim-treesitter grammars) remain in rtp.
  performance = {
    reset_packpath = is_windows,
    rtp = { reset = is_windows },
  },
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "nordic" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
