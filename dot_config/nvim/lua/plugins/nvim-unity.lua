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

-- Resolve Unity binary from the project's ProjectSettings/ProjectVersion.txt.
-- Falls back to the latest installed version if the exact version isn't found.
local function resolve_unity_path()
    local hub_editors = vim.fn.expand("~/Unity/Hub/Editor")

    -- Walk up from cwd to find ProjectSettings/ProjectVersion.txt
    local dir = vim.fn.getcwd()
    while dir ~= "/" and not dir:match("^%a:[\\/]?$") do
        local version_file = dir .. "/ProjectSettings/ProjectVersion.txt"
        local f = io.open(version_file, "r")
        if f then
            local content = f:read("*a")
            f:close()
            local version = content:match("m_EditorVersion:%s*(%S+)")
            if version then
                local path = hub_editors .. "/" .. version .. "/Editor/Unity"
                if vim.fn.executable(path) == 1 then
                    return path
                end
            end
        end
        dir = vim.fn.fnamemodify(dir, ":h")
    end

    -- Fallback: pick the latest installed version
    local installs = vim.fn.glob(hub_editors .. "/*/Editor/Unity", false, true)
    if #installs > 0 then
        table.sort(installs)
        return installs[#installs]
    end

    return nil
end

local unity_path = resolve_unity_path()

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
