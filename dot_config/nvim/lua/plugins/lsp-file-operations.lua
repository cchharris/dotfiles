return {
  {
    "antosha417/nvim-lsp-file-operations",
    event = "LspAttach",
    dependencies = {
      "nvim-lua/plenary.nvim",
    -- neo-tree removed from deps to avoid force-loading it on LspAttach
    -- "nvim-neo-tree/neo-tree.nvim",
    },
	opts = {
	},
  },
}
