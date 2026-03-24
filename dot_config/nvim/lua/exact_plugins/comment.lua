return {
    'numToStr/Comment.nvim',
    opts = {
        --[[
            CommentCtx                                            *comment.utils.CommentCtx*
                Comment context

                Fields: ~
                    {ctype}    (integer)       See |comment.utils.ctype|
                    {cmode}    (integer)       See |comment.utils.cmode|
                    {cmotion}  (integer)       See |comment.utils.cmotion|
                    {range}    (CommentRange)


            CommentRange                                        *comment.utils.CommentRange*
                Range of the selection that needs to be commented

                Fields: ~
                    {srow}  (integer)  Starting row
                    {scol}  (integer)  Starting column
                    {erow}  (integer)  Ending row
                    {ecol}  (integer)  Ending column
            --]]
        pre_hook = function(ctx)
            local opts = require('undo-glow.utils').merge_command_opts("UgComment")
            require('undo-glow').highlight_changes(opts)
        end,
        -- post_hook = function(ctx)
        --     local opts = {}
        --     opts = require('undo-glow.utils').merge_command_opts("UgComment", opts)
        --     require('undo-glow').highlight_region(vim.tbl_extend("force", opts, {
        --         s_row = ctx.range.srow,
        --         s_col = ctx.range.scol,
        --         e_row = ctx.range.erow,
        --         e_col = ctx.range.ecol,
        --     }))
        -- end,
    }
}
