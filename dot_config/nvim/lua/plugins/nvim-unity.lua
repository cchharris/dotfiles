-- nvim-unity-sync: synchronise Unity .csproj files with Neovim edits.
-- Repo: https://github.com/apyra/nvim-unity-sync
--
-- NOTE: auto-sync on file create/rename/delete requires nvim-tree.
-- This config uses neo-tree, so those events won't fire.
-- Manual `:Usync` covers the workflow. To enable auto-sync, add
-- nvim-tree with hijack_netrw_behavior = "disabled".
--
-- unity_path is machine- and version-specific. Set the variable below
-- to your Unity editor binary path. Leave nil to disable `:Uopen`
-- while keeping `:Ustatus` and `:Usync` functional.
--   Windows: "C:/Program Files/Unity/Hub/Editor/<version>/Editor/Unity.exe"
--   Linux:   "/opt/unity/Editor/Unity"
--   macOS:   "/Applications/Unity/Hub/Editor/<version>/Unity.app/Contents/MacOS/Unity"

local unity_path = vim.fn.expand("~/Unity/Hub/Editor/6000.4.3f1/Editor/Unity")

return {
    "apyra/nvim-unity-sync",
    ft = { "cs", "unity", "prefab", "asset", "meta" },
    cmd = { "Ustatus", "Usync", "Uopen" },
    config = function()
        require("unity.plugin").setup({
            unity_path = unity_path,
            unity_cs_template = true,
        })
    end,
}
