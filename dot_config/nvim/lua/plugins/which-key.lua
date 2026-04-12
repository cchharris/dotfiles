return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    triggers = {
      { "<auto>", mode = "nixsotc" },
      { "\\", mode = "t" },
    },
    spec = {
      { "<leader>b",  group = "Buffers",        icon = "󰓩" },
      { "<leader>c",  group = "Code",            icon = "" },
      { "<leader>f",  group = "Find",            icon = "" },
      { "<leader>fc", group = "Config",          icon = "" },
      { "<leader>fg", group = "Git",             icon = "󰊢" },
      { "<leader>g",  group = "Git",             icon = "󰊢" },
      { "<leader>gh", group = "GitHub",          icon = "" },
      { "<leader>i",  group = "Packages",        icon = "󰏖" },
      { "<leader>n",  group = "Minimap",         icon = "󰍉" },
      { "<leader>nb", group = "Buffer minimap",  icon = "󰍉" },
      { "<leader>nt", group = "Tab minimap",     icon = "󰍉" },
      { "<leader>nw", group = "Window minimap",  icon = "󰍉" },
      { "<leader>o",  group = "Overseer",        icon = "󰑮" },
      { "<leader>s",  group = "Sidekick",        icon = "" },
      { "\\",         group = "Claude shortcuts", mode = "t", icon = "" },
      { "<leader>t",  group = "Test",            icon = "" },
      { "<leader>T",  group = "Terminal",        icon = "" },
      { "<leader>w",  group = "Window",          icon = "󱂬" },
      { "<leader>x",  group = "Diagnostics",     icon = "󰒡" },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
