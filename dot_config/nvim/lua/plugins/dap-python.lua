-- DAP adapter for Python. Auto-detects the active venv's python; falls back to
-- the system interpreter via `python3 -m debugpy`.
return {
    'mfussenegger/nvim-dap-python',
    ft = 'python',
    dependencies = {
        'mfussenegger/nvim-dap',
        'rcarriga/nvim-dap-ui',
    },
    config = function()
        local function resolve_python()
            local venv = os.getenv('VIRTUAL_ENV') or os.getenv('CONDA_PREFIX')
            if venv and venv ~= '' then
                return venv .. (vim.fn.has('win32') == 1 and '/Scripts/python.exe' or '/bin/python')
            end
            return vim.fn.has('win32') == 1 and 'python' or 'python3'
        end
        require('dap-python').setup(resolve_python())
    end,
    keys = {
        {
            '<leader>dpm',
            function() require('dap-python').test_method() end,
            ft = 'python',
            desc = '<Dap-Python>  Debug test method',
        },
        {
            '<leader>dpc',
            function() require('dap-python').test_class() end,
            ft = 'python',
            desc = '<Dap-Python>  Debug test class',
        },
        {
            '<leader>dps',
            function() require('dap-python').debug_selection() end,
            mode = 'v',
            ft = 'python',
            desc = '<Dap-Python>  Debug selection',
        },
    },
}
