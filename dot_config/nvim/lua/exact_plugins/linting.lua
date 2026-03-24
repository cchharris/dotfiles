return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require("lint")

        lint.linters_by_ft = {
            dockerfile = { "hadolint" },
            javascript = { "eslint_d" },
            javascriptreact = { "eslint_d" },
            sh = { "shellcheck" },
            bash = { "shellcheck" },
            terraform = { "tflint" },
            tf = { "tflint" },
            typescript = { "eslint_d" },
            typescriptreact = { "eslint_d" },
            yaml = { "yamllint" },
        }

        -- Run from project root so linters pick up root-level configs
        local root_cwd = function(markers)
            return function()
                return vim.fs.root(0, markers)
            end
        end

        lint.linters.eslint_d = vim.tbl_deep_extend('force', lint.linters.eslint_d, {
            cwd = root_cwd({ ".eslintrc", ".eslintrc.js", ".eslintrc.json", "eslint.config.js", "eslint.config.mjs", "package.json" }),
        })
        lint.linters.yamllint = vim.tbl_deep_extend('force', lint.linters.yamllint, {
            cwd = root_cwd({ ".yamllint", ".yamllint.yaml", ".yamllint.yml", ".git" }),
        })
        lint.linters.tflint = vim.tbl_deep_extend('force', lint.linters.tflint, {
            cwd = root_cwd({ '.tflint.hcl', '.git' }),
        })

        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
            callback = function()
                lint.try_lint()
            end,
        })
    end,
}
