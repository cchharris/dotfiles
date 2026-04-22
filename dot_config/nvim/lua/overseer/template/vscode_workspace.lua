-- Replaces the builtin vscode template with one that reads .code-workspace folders.
-- Falls back to single .vscode/tasks.json search when no workspace file is found.
local files = require("overseer.files")
local variables = require("overseer.vscode.variables")
local vs_util = require("overseer.vscode.vs_util")
local vscode = require("overseer.vscode")

-- Extract folder paths from a .code-workspace file.
-- Full JSON parsing is unreliable (JSONC with block comments, trailing commas, etc.),
-- so we scan for "path": "..." entries inside the "folders" array instead.
local function get_workspace_folders(path)
    local f = io.open(path, "r")
    if not f then return {} end
    local content = f:read("*a")
    f:close()
    -- Strip /* */ block comments (multiline)
    local parts = {}
    local i = 1
    while i <= #content do
        local s = content:find("/%*", i)
        if not s then parts[#parts + 1] = content:sub(i); break end
        parts[#parts + 1] = content:sub(i, s - 1)
        local e = content:find("%*/", s + 2)
        if not e then break end
        i = e + 2
    end
    content = table.concat(parts)
    -- Strip // line comments
    content = content:gsub("//[^\n]*", "")
    -- Extract the "folders": [...] section, then grab each "path" value
    local folders_block = content:match('"folders"%s*:%s*%[(.-)%]')
    if not folders_block then return {} end
    local paths = {}
    for p in folders_block:gmatch('"path"%s*:%s*"([^"]*)"') do
        table.insert(paths, p)
    end
    return paths
end

local os_key = files.is_windows and "windows" or (files.is_mac and "osx" or "linux")

local function load_folder_tasks(folder_path, ret)
    local tasks_file = vim.fs.joinpath(folder_path, ".vscode", "tasks.json")
    if not vim.uv.fs_stat(tasks_file) then return end

    local content = vs_util.load_tasks_file(tasks_file)
    if not content or not content.tasks then return end

    local global_defaults = {}
    for k, v in pairs(content) do
        if k ~= "version" and k ~= "tasks" then
            global_defaults[k] = v
        end
    end
    if content[os_key] then
        global_defaults = vim.tbl_deep_extend("force", global_defaults, content[os_key])
    end

    local precalculated_vars = variables.precalculate_vars()
    precalculated_vars.workspaceFolder = folder_path
    precalculated_vars.workspaceFolderBasename = vim.fs.basename(folder_path)

    for _, task in ipairs(content.tasks) do
        local defn = vim.tbl_deep_extend("force", global_defaults, task)
        defn = vim.tbl_deep_extend("force", defn, task[os_key] or {})
        local tmpl = vscode.convert_vscode_task(defn, precalculated_vars)
        if tmpl then
            table.insert(ret, tmpl)
        end
    end
end

return {
    generator = function(opts)
        local cwd = vim.fn.getcwd()
        local ret = {}

        local workspace_files = vim.fs.find(function(name)
            return name:match("%.code%-workspace$")
        end, { upward = true, type = "file", path = cwd, limit = math.huge })

        local seen_folders = {}
        for _, workspace_file in ipairs(workspace_files) do
            local workspace_dir = vim.fs.dirname(workspace_file)
            for _, rel_path in ipairs(get_workspace_folders(workspace_file)) do
                local folder_path = vim.fs.normalize(
                    vim.fs.joinpath(workspace_dir, rel_path)
                )
                if not seen_folders[folder_path] then
                    seen_folders[folder_path] = true
                    load_folder_tasks(folder_path, ret)
                end
            end
        end

        -- Fall back to standard upward search when no workspace file found
        if #ret == 0 then
            local tasks_file = vs_util.get_tasks_file(cwd, opts.dir)
            if tasks_file then
                local folder_path = vim.fs.dirname(vim.fs.dirname(tasks_file))
                load_folder_tasks(folder_path, ret)
            end
        end

        if #ret == 0 then
            return "No VS Code tasks found"
        end
        return ret
    end,
}
