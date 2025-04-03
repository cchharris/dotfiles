local dashboard = {  
	  { section = "header" },
		{ icon = " ", key = "f", desc = "Find File", action = ":lua require('telescope.builtin').fd()" },
      { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
      { icon = " ", key = "g", desc = "Find Text", action = ":lua require('telescope').extensions.live_grep_args.live_grep_args()" },
      { icon = " ", key = "r", desc = "Recent Files", action = ":lua require('telescope.builtin').oldfiles()" },
      { icon = " ", key = "c", desc = "Config", action = ":lua require('telescope.builtin').fd({cwd = vim.fn.stdpath('config')})" },
      { icon = " ", key = "C", desc = "Chezmoi", action = ":lua require('telescope').extensions.chezmoi.find_files()" },
      { icon = " ", key = "s", desc = "Restore Session", enabled = function() return require('auto-session').session_exists_for_cwd() end, action = ":lua require('auto-session').RestoreSession()" },
      { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
      { icon = " ", key = "q", desc = "Quit", action = ":qa" },
}


return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
	-- dependencies = {
	--   'rmagatti/auto-session',
	-- },
  ---@type snacks.Config
  config = function()
        require("snacks").setup({
            -- Your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
            bigfile = { enabled = true },
            bufdelete = { enabled = true},
            dashboard = { enabled = true, sections = dashboard },
            explorer = { enabled = true },
            indent = { enabled = true },
            input = { enabled = true },
            lazygit = { enabled = true },
            notifier = { enabled = true },
            picker = { enabled = true },
            quickfile = { enabled = true },
            scope = { enabled = true },
            scroll = { enabled = true },
            statuscolumn = { enabled = true },
            terminal = { enabled = true },
            words = { enabled = true },
        });
        ---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
        local progress = vim.defaulttable()
        vim.api.nvim_create_autocmd("LspProgress", {
          ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
          callback = function(ev)
            local client = vim.lsp.get_client_by_id(ev.data.client_id)
            local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
            if not client or type(value) ~= "table" then
              return
            end
            local p = progress[client.id]

            for i = 1, #p + 1 do
              if i == #p + 1 or p[i].token == ev.data.params.token then
                p[i] = {
                  token = ev.data.params.token,
                  msg = ("[%3d%%] %s%s"):format(
                    value.kind == "end" and 100 or value.percentage or 100,
                    value.title or "",
                    value.message and (" **%s**"):format(value.message) or ""
                  ),
                  done = value.kind == "end",
                }
                break
              end
            end

            local msg = {} ---@type string[]
            progress[client.id] = vim.tbl_filter(function(v)
              return table.insert(msg, v.msg) or not v.done
            end, p)

            local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
            vim.notify(table.concat(msg, "\n"), "info", {
              id = client.id .. "lsp_progress",
              title = client.name,
              timeout = value.kind == "end" and 500 or 0, -- keep it for a while if it's not done
              opts = function(notif)
                notif.icon = #progress[client.id] == 0 and " "
                  or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
              end,
            })
          end,
        })
    end,
}
