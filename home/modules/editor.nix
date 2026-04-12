# Editor configuration (neovim)
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.home.editor;
in {
  options.cchharris.home.editor = {
    enable = lib.mkEnableOption "editor configuration (neovim)";
  };

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      plugins = with pkgs.vimPlugins; [
        # Theme
        tokyonight-nvim

        # Syntax and LSP
        nvim-treesitter.withAllGrammars
        nvim-lspconfig

        # Completion
        nvim-cmp
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        luasnip
        cmp_luasnip

        # UI enhancements
        lualine-nvim
        nvim-web-devicons
        telescope-nvim
        plenary-nvim

        # Git
        gitsigns-nvim

        # File tree
        nvim-tree-lua

        # Quality of life
        comment-nvim
        nvim-autopairs
        indent-blankline-nvim
      ];

      initLua = ''
        -- Basic settings
        vim.opt.number = true
        vim.opt.relativenumber = true
        vim.opt.mouse = 'a'
        vim.opt.ignorecase = true
        vim.opt.smartcase = true
        vim.opt.hlsearch = false
        vim.opt.wrap = false
        vim.opt.breakindent = true
        vim.opt.tabstop = 2
        vim.opt.shiftwidth = 2
        vim.opt.expandtab = true
        vim.opt.signcolumn = 'yes'
        vim.opt.termguicolors = true
        vim.opt.clipboard = 'unnamedplus'
        vim.opt.scrolloff = 8
        vim.opt.updatetime = 250

        -- Leader key
        vim.g.mapleader = ' '
        vim.g.maplocalleader = ' '

        -- Theme
        vim.cmd[[colorscheme tokyonight-night]]

        -- Lualine
        require('lualine').setup {
          options = {
            theme = 'tokyonight'
          }
        }

        -- Telescope keymaps
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
        vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags' })

        -- Nvim-tree
        require('nvim-tree').setup()
        vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle file tree' })

        -- Gitsigns
        require('gitsigns').setup()

        -- Comment
        require('Comment').setup()

        -- Autopairs
        require('nvim-autopairs').setup()

        -- Indent blankline
        require('ibl').setup()
      '';
    };

    home.packages = with pkgs; [
      # LSP servers
      nil                        # Nix LSP
      lua-language-server        # Lua LSP
      typescript-language-server # TypeScript/JavaScript LSP
      bash-language-server       # Bash LSP
    ];
  };
}
