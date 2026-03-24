-- Lazy.nvim
return {
  'xvzc/chezmoi.nvim',
	event = 'VeryLazy',
  dependencies = { 'nvim-lua/plenary.nvim' },
	opts = {
      edit = {
        watch = false,
        force = false,
      },
      notification = {
        on_open = true,
        on_apply = true,
        on_watch = false,
      },
      telescope = {
        select = { "<CR>" },
      },
    },
	cmd = {
		"ChezmoiEdit",
		"ChezmoiList"
	}
}
