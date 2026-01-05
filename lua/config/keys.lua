local utils = require("config.utils")
require("which-key").add({{"<leader>s", group = "[S]earch"}, {"<leader>g", group = "[G]oto"}, {"<leader>c", group = "[C]onfig"}, {"<leader>t", group = "[T]oggle"}, {"<leader>d", group = "[D]ocument"}, {"<leader>w", group = "[W]orkspace"}, {"<leader>o", group = "[O]verseer"}})
local builtin = require("telescope.builtin")
local kset = vim.keymap.set
kset("n", "<leader>sf", builtin.find_files, {desc = "[S]earch [F]iles"})
kset("n", "<leader>sg", builtin.live_grep, {desc = "[S]earch [G]rep"})
kset("n", "<leader>sb", builtin.buffers, {desc = "[S]earch [B]uffers"})
kset("n", "<leader>sh", builtin.help_tags, {desc = "[S]earch [H]elp Tags"})
kset("n", "<leader>sr", builtin.resume, {desc = "[S]earch [R]esume"})
local function _1_()
  return builtin.find_files({cwd = vim.fn.stdpath("config")})
end
kset("n", "<leader>sn", _1_, {desc = "[S]earch [N]eovim files"})
kset("n", "<leader>ss", builtin.lsp_document_symbols, {desc = "[S]earch Document [S]ymbols"})
kset("n", "<Esc>", "<cmd>nohlsearch<CR>")
kset("n", "<leader>q", vim.diagnostic.setloclist, {desc = "Open diagnostic [Q]uickfix list"})
kset("t", "<Esc><Esc>", "<C-\\><C-n>", {desc = "Exit terminal mode"})
do
  local _2_ = io.popen("odin root", "r")
  if (nil ~= _2_) then
    local file = _2_
    local odin_root = file:read("*a")
    file:close()
    local function _3_()
      return builtin.find_files({cwd = odin_root, prompt_title = "Search Odin Files"})
    end
    kset("n", "<leader>sof", _3_, {desc = "[S]earch [O]din [F]iles"})
    local function _4_()
      return builtin.live_grep({cwd = odin_root, prompt_title = "Grep Odin Files"})
    end
    kset("n", "<leader>sog", _4_, {desc = "[S]earch [O]din [G]rep"})
  elseif (_2_ == nil) then
  else
  end
end
local loop = (vim.uv or vim.loop)
if loop.fs_stat("/usr/src/linux") then
  local function _6_()
    local function _7_()
      return builtin.find_files({cwd = "/usr/src/linux/", prompt_title = "Search Linux Files"})
    end
    kset("n", "<leader>slf", _7_, {desc = "[S]earch [L]inux [F]iles"})
    local function _8_()
      return builtin.live_grep({cwd = "/usr/src/linux/", prompt_title = "Grep Linux Files"})
    end
    return kset("n", "<leader>slg", _8_, {desc = "[S]earch [L]inux [G]rep"})
  end
  _6_()
else
end
local function _10_()
  local overseer = require("overseer")
  local tasks = overseer.list_tasks({recent_first = true})
  if vim.tbl_isempty(tasks) then
    return vim.notify("No tasks found", vim.log.levels.WARN)
  else
    return overseer.run_action(tasks[1], "restart")
  end
end
vim.api.nvim_create_user_command("OverseerRestartLast", _10_, {})
kset("n", "<leader>or", "<ESC>:OverseerRun<CR>", {desc = "[O]verseer [R]un"})
kset("n", "<leader>orl", "<ESC>:OverseerRestartLast<CR>", {desc = "[O]verseer [R]un [L]ast"})
kset("n", "<leader>b", "<ESC>:OverseerRestartLast<CR>", {desc = "Overseer Run Last"})
local function _12_()
  package.loaded = nil
  return vim.cmd(("source " .. (vim.fn.stdpath("config") .. "/init.lua")))
end
kset("n", "<leader>cs", _12_, {desc = "[C]onfig [S]ource"})
kset("n", "<leader><leader>", "source", {desc = "Source current file."})
local function _13_()
  local name = vim.api.nvim_buf_get_name(0)
  local lua_name = utils["change-extension"](name, "lua")
  return vim.cmd(("source " .. lua_name))
end
kset("n", "<leader>cfs", _13_, {desc = "[C]onfig [F]ile [S]ource"})
return nil
