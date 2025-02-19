local home = os.getenv('USERPROFILE')
local configpath = home..'/.config/nvim/'
package.path = configpath..'lua/?.lua'..';'..package.path
package.path = configpath..'?.lua'..';'..package.path
vim.opt.rtp:prepend(configpath)
require('init')
