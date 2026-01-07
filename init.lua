local utils = require("config.utils")
local vo = vim.opt
local vg = vim.g
local va = vim.api
local sysname = vim.loop.os_uname().sysname
local windows = (sysname == "Windows_NT")
local config_path = vim.fn.stdpath("config")
vg.mapleader = " "
vg.maplocalleader = " "
vg.have_nerd_font = true
vo.number = true
vo.relativenumber = true
vo.mouse = "a"
vo.showmode = true
if (vim.fn.has("linux") ~= 0) then
  vg.clipboard = "wl-copy"
else
end
local function _2_()
  vo.clipboard = "unnamedplus"
  return nil
end
vim.schedule(_2_)
vo.breakindent = true
vo.undofile = true
vo.ignorecase = true
vo.smartcase = true
vo.signcolumn = "yes"
vo.updatetime = 250
vo.timeoutlen = 300
vo.splitright = true
vo.splitbelow = true
vo.list = true
vo.listchars = {nbsp = "\226\144\163", tab = "\194\187 ", trail = "\194\183"}
vo.inccommand = "split"
vo.virtualedit = "block"
vo.cursorline = true
vo.scrolloff = 10
vg.c_syntax_for_h = 1
vo.tabstop = 4
vo.softtabstop = 4
vo.shiftwidth = 4
vo.expandtab = true
vo.formatoptions = "rqnl1j"
vo.termguicolors = true
vo.guifont = "JetBrainsMono NF"
if vg.neovide then
  vg.neovide_cursor_animation_length = 0
else
end
local function schedule_notify(message, level_3f)
  local function _4_()
    return vim.notify(message, level_3f)
  end
  return vim.schedule(_4_)
end
local gr = vim.api.nvim_create_augroup("vimrc-default-group", {})
local function _5_()
  vim.cmd("setlocal formatoptions-=c formatoptions-=o")
  return nil
end
vim.api.nvim_create_autocmd("FileType", {group = gr, pattern = nil, callback = _5_, desc = "Proper 'formatoptions'"})
vim.filetype.add({extension = {sjson = "sjson"}})
local group = va.nvim_create_augroup("vimrc", {clear = true})
local function fnl_buf_write_post(ev)
  local file_name = tostring(va.nvim_buf_get_name(ev.buf))
  local _6_
  if windows then
    _6_ = (config_path .. "\\bin\\fennel.exe")
  else
    _6_ = (config_path .. "/bin/fennel")
  end
  local function fennel_compile_on_exit_command(completed)
    if completed then
      if (completed.code == 0) then
        local new_file = utils["change-extension"](file_name, "lua")
        local _8_, _9_ = io.open(new_file, "w+")
        if (nil ~= _8_) then
          local file = _8_
          file:write(completed.stdout)
          file:close()
          schedule_notify(((("Compiled " .. file_name) .. " to ") .. new_file))
        elseif ((_8_ == nil) and (nil ~= _9_)) then
          local err_msg = _9_
          schedule_notify(((("Could not open file " .. new_file) .. ": ") .. err_msg))
        else
        end
      else
        schedule_notify((("stdout:\n" .. completed.stdout) .. ("stderr:\n" .. completed.stderr)), vim.log.levels.ERROR)
      end
    else
    end
    return nil
  end
  vim.system({_6_, "--compile", file_name}, {text = true}, fennel_compile_on_exit_command)
  return nil
end
va.nvim_create_autocmd({"BufWritePost"}, {group = group, pattern = {"*.fnl"}, callback = fnl_buf_write_post})
require("config.plugins")
require("config.keys")
require("config.lsp")
return nil
