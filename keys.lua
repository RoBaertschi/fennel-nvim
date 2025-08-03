require("which-key").add({{"<leader>s", group = "[S]earch"}, {"<leader>g", group = "[G]oto"}, {"<leader>c", group = "[C]ode"}, {"<leader>t", group = "[T]oggle"}, {"<leader>d", group = "[D]ocument"}, {"<leader>w", group = "[W]orkspace"}, {"<leader>o", group = "[O]verseer"}})
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>sf", builtin.find_files, {desc = "[S]earch [F]iles"})
vim.keymap.set("n", "<leader>sg", builtin.live_grep, {desc = "[S]earch [G]rep"})
vim.keymap.set("n", "<leader>sb", builtin.buffers, {desc = "[S]earch [B]uffers"})
vim.keymap.set("n", "<leader>sh", builtin.help_tags, {desc = "[S]earch [H]elp Tags"})
vim.keymap.set("n", "<leader>sr", builtin.resume, {desc = "[S]earch [R]esume"})
local function _1_()
  return builtin.find_files({cwd = vim.fn.stdpath("config")})
end
vim.keymap.set("n", "<leader>sn", _1_, {desc = "[S]earch [N]eovim files"})
vim.keymap.set("n", "<leader>ss", builtin.lsp_document_symbols, {desc = "[S]earch Document [S]ymbols"})
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, {desc = "Open diagnostic [Q]uickfix list"})
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", {desc = "Exit terminal mode"})
do
  local _2_ = io.popen("odin root", "r")
  if (nil ~= _2_) then
    local file = _2_
    local odin_root = file:read("*a")
    file:close()
    local function _3_()
      return builtin.find_files({cwd = odin_root, prompt_title = "Search Odin Files"})
    end
    vim.keymap.set("n", "<leader>sof", _3_, {desc = "[S]earch [O]din [F]iles"})
    local function _4_()
      return builtin.live_grep({cwd = odin_root, prompt_title = "Grep Odin Files"})
    end
    vim.keymap.set("n", "<leader>sog", _4_, {desc = "[S]earch [O]din [G]rep"})
  elseif (_2_ == nil) then
  else
  end
end
local function _6_()
  local overseer = require("overseer")
  local tasks = overseer.list_tasks({recent_first = true})
  if vim.tbl_isempty(tasks) then
    return vim.notify("No tasks found", vim.log.levels.WARN)
  else
    return overseer.run_action(tasks[1], "restart")
  end
end
vim.api.nvim_create_user_command("OverseerRestartLast", _6_, {})
vim.keymap.set("n", "<leader>or", "<ESC>:OverseerRun<CR>", {desc = "[O]verseer [R]un"})
vim.keymap.set("n", "<leader>orl", "<ESC>:OverseerRestartLast<CR>", {desc = "[O]verseer [R]un [L]ast"})
vim.keymap.set("n", "<leader>b", "<ESC>:OverseerRestartLast<CR>", {desc = "Overseer Run Last"})
local vks = vim.keymap.set
local function _8_()
  return vim.cmd(("source " .. (vim.fn.stdpath("config") .. "/init.lua")))
end
vks("n", "<leader>cs", _8_, {desc = "[C]onfig [S]ource"})
return nil
