local data = vim.fn.stdpath("data")
local config = vim.fn.stdpath("config")
local loop = (vim.uv or vim.loop)
local plugins = {}
local pack_dir = (data .. "/site/pack")
local function mkdir(dir)
  if not loop.fs_stat(dir) then
    local d
    local function _1_()
      do local _ = vim.fn.mkdir end
      return dir
    end
    d = vim.schedule_wrap(_1_, 0)
    d()
  else
  end
  return nil
end
mkdir(pack_dir)
local function plugin_path(plugin)
  return ((((pack_dir .. "/") .. plugin) .. "/start/") .. plugin)
end
local function installed(plugin)
  if loop.fs_stat(plugin_path(plugin)) then
    return true
  else
    return false
  end
end
local function add_plugin_to_rtp(plugin)
  assert(installed(plugin))
  return vim.opt.rtp:append(plugin_path(plugin))
end
local function clone_plugin(src, to, branch_3f)
  mkdir(to)
  local result
  do
    local sync_output
    local _4_
    if branch_3f then
      _4_ = ("--branch=" .. branch_3f)
    else
      _4_ = nil
    end
    sync_output = vim.system({"git", "clone", _4_, src, to})
    result = sync_output:wait()
  end
  if (result.code == 0) then
    return nil
  else
    return result
  end
end
local function add_plugin(name, src, branch_3f)
  if not installed(name) then
    local _7_ = clone_plugin(src, plugin_path(name), (branch_3f or nil))
    if (nil ~= _7_) then
      local failed = _7_
      return error(vim.inspect(failed))
    elseif (_7_ == nil) then
      return nil
    else
      return nil
    end
  else
    return nil
  end
end
add_plugin("tokyonight", "https://github.com/folke/tokyonight.nvim.git")
add_plugin("nvim-treesitter", "https://github.com/nvim-treesitter/nvim-treesitter", "main")
add_plugin("which-key", "https://github.com/folke/which-key.nvim")
add_plugin("mason", "https://github.com/mason-org/mason.nvim")
add_plugin("lsp-config", "https://github.com/neovim/nvim-lspconfig")
add_plugin("mini", "https://github.com/echasnovski/mini.nvim")
add_plugin("plenary", "https://github.com/nvim-lua/plenary.nvim")
add_plugin("harpoon", "https://github.com/ThePrimeagen/harpoon", "harpoon2")
add_plugin("blink.cmp", "https://github.com/saghen/blink.cmp", "v1.7.0")
add_plugin("conform", "https://github.com/stevearc/conform.nvim")
add_plugin("todo-comments", "https://github.com/folke/todo-comments.nvim")
add_plugin("rivial", "https://github.com/robaertschi/rivial")
vim.cmd("packl!")
vim.cmd("colorscheme tokyonight-night")
local group = vim.api.nvim_create_augroup("vimrc-treesitter", {clear = true})
local function _10_(args)
  _G.assert((nil ~= args), "Missing argument args on /home/robin/.config/nvim/lua/config/plugins.fnl:74")
  require("nvim-treesitter.parsers").odin["install_info"] = {url = "https://github.com/RoBaertschi/tree-sitter-odin", branch = "master"}
  require("nvim-treesitter.parsers")["sjson"] = {install_info = {url = "https://github.com/RoBaertschi/tree-sitter-sjson", revision = "c9b7e606de8ec376a4641e7db1ca5722d5afff2d"}, maintainers = {"@RoBaertschi"}, tier = 2}
  return nil
end
vim.api.nvim_create_autocmd("User", {pattern = "TSUpdate", group = group, callback = _10_})
local nvim_treesitter = require("nvim-treesitter")
nvim_treesitter.setup({})
vim.cmd("TSUpdate")
local to_install = {"bash", "c", "diff", "html", "lua", "luadoc", "markdown", "markdown_inline", "query", "vim", "vimdoc"}
do
  local installed0 = nvim_treesitter.get_installed()
  local install = {}
  for _, value in ipairs(to_install) do
    local already_installed = false
    for _0, found in ipairs(installed0) do
      if found then
        already_installed = true
      else
      end
    end
    if not already_installed then
      table.insert(install, value)
    else
    end
  end
  nvim_treesitter.install(install)
end
local function _13_(args)
  _G.assert((nil ~= args), "Missing argument args on /home/robin/.config/nvim/lua/config/plugins.fnl:116")
  do
    local attach
    local function _14_(buf, language)
      _G.assert((nil ~= language), "Missing argument language on /home/robin/.config/nvim/lua/config/plugins.fnl:119")
      _G.assert((nil ~= buf), "Missing argument buf on /home/robin/.config/nvim/lua/config/plugins.fnl:119")
      if not vim.treesitter.language.add(language) then
        return false
      else
        vim.treesitter.start(buf, language)
        vim.wo.foldlevel = 99
        vim.opt.foldlevelstart = -1
        vim.opt.foldnestmax = 99
        return true
      end
    end
    attach = _14_
    local language = vim.treesitter.language.get_lang(args.match)
    if (language and true) then
      local and_16_ = not attach(args.buf, language)
      if and_16_ then
        local function _17_(item)
          _G.assert((nil ~= item), "Missing argument item on /home/robin/.config/nvim/lua/config/plugins.fnl:138")
          return (item == language)
        end
        and_16_ = vim.iter(require("nvim-treesitter").get_available()):any(_17_)
      end
      if and_16_ then
        local installing = require("nvim-treesitter.install").install(language)
        local function _18_()
          return attach(args.buf, language)
        end
        installing:await(_18_)
      else
      end
    else
    end
  end
  return nil
end
vim.api.nvim_create_autocmd("FileType", {group = group, callback = _13_})
local which_key = require("which-key")
which_key.setup({})
local function _21_()
  return which_key.show({global = false})
end
vim.keymap.set("n", "<leader>?", _21_)
local mason = require("mason")
mason.setup({})
require("mini.icons").setup()
require("mini.icons").setup()
local mini_pick = require("mini.pick")
mini_pick.setup()
local harpoon = require("harpoon")
harpoon:setup()
require("mini.extra").setup()
require("mini.files").setup({windows = {preview = true}})
require("mini.align").setup({})
require("mini.ai").setup({n_lines = 500})
require("mini.surround").setup({})
local statusline = require("mini.statusline")
statusline.setup({use_icons = true})
local function _22_()
  return "%2l:%-2v"
end
statusline["section_location"] = _22_
local function _23_(bufnr)
  _G.assert((nil ~= bufnr), "Missing argument bufnr on /home/robin/.config/nvim/lua/config/plugins.fnl:188")
  local disable_filetype = {c = true, cpp = true}
  if disable_filetype[vim.bo[bufnr].filetype] then
    return nil
  else
    return {timeout_ms = 500, lsp_format = "fallback"}
  end
end
require("conform").setup({format_on_save = _23_, formatters_by_ft = {lua = {"stylua"}}, notify_on_error = false})
local function _25_()
  return require("conform").format({async = true, lsp_format = "fallback"})
end
vim.keymap.set("n", "<leader>f", _25_)
require("todo-comments").setup({highlight = {pattern = {".*<(KEYWORDS)\\s*:", ".*<(KEYWORDS)\\s*\\(\\w*\\)\\s*:"}, keyword = "bg"}, search = {pattern = "\\b(KEYWORDS)\\s*(\\(\\w*\\))?\\s*:"}, signs = false})
return nil
