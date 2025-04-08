
vim.cmd [[let &shell = executable('pwsh') ? 'pwsh' : 'powershell']]
vim.cmd [[let &shellcmdflag = '-NoLogo -NonInteractive -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues[''Out-File:Encoding'']=''utf8'';$PSStyle.OutputRendering=''plaintext'';Remove-Alias -Force -ErrorAction SilentlyContinue tee;']]
vim.cmd [[let &shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode']]
vim.cmd [[let &shellpipe  = '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode']]
vim.cmd [[set shellquote= shellxquote=]]

local home = os.getenv('USERPROFILE')
local configpath = home..'/.config/nvim/'

package.path = configpath..'lua/?.lua'..';'..package.path
package.path = configpath..'?.lua'..';'..package.path
vim.opt.rtp:prepend(configpath)
require('init')
