local utils = require("config.utils")
require("which-key").add({{"<leader>s", group = "[S]earch"}, {"<leader>g", group = "[G]oto"}, {"<leader>c", group = "[C]onfig"}, {"<leader>t", group = "[T]oggle"}, {"<leader>d", group = "[D]ocument"}, {"<leader>w", group = "[W]orkspace"}, {"<leader>o", group = "[O]verseer"}, {"<leader>p", group = "[P]roject"}})
local builtin = MiniPick.builtin
local kset = vim.keymap.set
local function _1_()
  return builtin.files()
end
kset("n", "<leader>sf", _1_, {desc = "[S]earch [F]iles"})
local function _2_()
  return builtin.grep_live()
end
kset("n", "<leader>sg", _2_, {desc = "[S]earch [G]rep"})
local function _3_()
  return builtin.buffers()
end
kset("n", "<leader>sb", _3_, {desc = "[S]earch [B]uffers"})
local function _4_()
  return builtin.help()
end
kset("n", "<leader>sh", _4_, {desc = "[S]earch [H]elp Tags"})
local function _5_()
  return builtin.resume()
end
kset("n", "<leader>sr", _5_, {desc = "[S]earch [R]esume"})
local function _6_()
  return builtin.files({}, {source = {cwd = vim.fn.stdpath("config")}})
end
kset("n", "<leader>sn", _6_, {desc = "[S]earch [N]eovim files"})
kset("n", "<Esc>", "<cmd>nohlsearch<CR>")
kset("n", "<leader>q", vim.diagnostic.setloclist, {desc = "Open diagnostic [Q]uickfix list"})
kset("t", "<Esc><Esc>", "<C-\\><C-n>", {desc = "Exit terminal mode"})
do
  local _7_ = io.popen("odin root", "r")
  if (nil ~= _7_) then
    local file = _7_
    local odin_root = file:read("*a")
    file:close()
    local function _8_()
      return builtin.files({}, {source = {cwd = odin_root, prompt_title = "Search Odin Files"}})
    end
    kset("n", "<leader>sof", _8_, {desc = "[S]earch [O]din [F]iles"})
    local function _9_()
      return builtin.grep_live({}, {source = {cwd = odin_root, prompt_title = "Grep Odin Files"}})
    end
    kset("n", "<leader>sog", _9_, {desc = "[S]earch [O]din [G]rep"})
  elseif (_7_ == nil) then
  else
  end
end
local loop = (vim.uv or vim.loop)
if loop.fs_stat("/usr/src/linux") then
  local function _11_()
    local function _12_()
      return builtin.find_files({}, {source = {cwd = "/usr/src/linux/", prompt_title = "Search Linux Files"}})
    end
    kset("n", "<leader>slf", _12_, {desc = "[S]earch [L]inux [F]iles"})
    local function _13_()
      return builtin.grep_live({}, {source = {cwd = "/usr/src/linux/", prompt_title = "Grep Linux Files"}})
    end
    return kset("n", "<leader>slg", _13_, {desc = "[S]earch [L]inux [G]rep"})
  end
  _11_()
else
end
local function _15_()
  local overseer = require("overseer")
  local tasks = overseer.list_tasks({recent_first = true})
  if vim.tbl_isempty(tasks) then
    return vim.notify("No tasks found", vim.log.levels.WARN)
  else
    return overseer.run_action(tasks[1], "restart")
  end
end
vim.api.nvim_create_user_command("OverseerRestartLast", _15_, {})
kset("n", "<leader>or", "<ESC>:OverseerRun<CR>", {desc = "[O]verseer [R]un"})
kset("n", "<leader>orl", "<ESC>:OverseerRestartLast<CR>", {desc = "[O]verseer [R]un [L]ast"})
kset("n", "<leader>b", "<ESC>:OverseerRestartLast<CR>", {desc = "Overseer Run Last"})
local function _17_()
  package.loaded = nil
  return vim.cmd(("source " .. (vim.fn.stdpath("config") .. "/init.lua")))
end
kset("n", "<leader>cs", _17_, {desc = "[C]onfig [S]ource"})
kset("n", "<leader><leader>", "source", {desc = "Source current file."})
local function _18_()
  local name = vim.api.nvim_buf_get_name(0)
  local lua_name = utils["change-extension"](name, "lua")
  return vim.cmd(("source " .. lua_name))
end
kset("n", "<leader>cfs", _18_, {desc = "[C]onfig [F]ile [S]ource"})
kset("n", "<leader>f", MiniFiles.open, {desc = "[F]iles"})
local function _19_()
  return MiniFiles.open(nil, false)
end
kset("n", "<leader>pf", _19_, {desc = "[P]roject [F]iles"})
local harpoon = require("harpoon")
local mini_pick = require("mini.pick")
local function _20_()
  local _21_
  do
    local tbl_21_ = {}
    local i_22_ = 0
    for _, v in ipairs(harpoon:list().items) do
      local val_23_ = v.value
      if (nil ~= val_23_) then
        i_22_ = (i_22_ + 1)
        tbl_21_[i_22_] = val_23_
      else
      end
    end
    _21_ = tbl_21_
  end
  local function _23_(buf_id, items, query)
    _G.assert((nil ~= query), "Missing argument query on /home/robin/.config/nvim/lua/config/keys.fnl:88")
    _G.assert((nil ~= items), "Missing argument items on /home/robin/.config/nvim/lua/config/keys.fnl:88")
    _G.assert((nil ~= buf_id), "Missing argument buf_id on /home/robin/.config/nvim/lua/config/keys.fnl:88")
    return mini_pick.default_show(buf_id, items, query, {show_icons = true})
  end
  return MiniPick.start({source = {items = _21_, show = _23_, name = "Harpoon"}})
end
kset("n", "<C-e>", _20_, {desc = "List all Harpoon files."})
local function _24_()
  return harpoon:list():add()
end
kset("n", "<leader>a", _24_, {desc = "[A]dd to Harpoon list."})
local function _25_()
  return harpoon:list():select(1)
end
kset("n", "<C-h>", _25_, {desc = "Select item 1 in the Harpoon list."})
local function _26_()
  return harpoon:list():select(2)
end
kset("n", "<C-j>", _26_, {desc = "Select item 2 in the Harpoon list."})
local function _27_()
  return harpoon:list():select(3)
end
kset("n", "<C-k>", _27_, {desc = "Select item 3 in the Harpoon list."})
local function _28_()
  return harpoon:list():select(4)
end
kset("n", "<C-l>", _28_, {desc = "Select item 4 in the Harpoon list."})
local function _29_()
  return harpoon:list():prev()
end
kset("n", "<C-S-P>", _29_, {desc = "Select next item in the Harpoon list."})
local function _30_()
  return harpoon:list():next()
end
kset("n", "<C-S-N>", _30_, {desc = "Select previous item in the Harpoon list."})
return nil
