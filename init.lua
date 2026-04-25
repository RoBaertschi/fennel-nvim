local utils = require("config.utils")
local vo = vim.opt
local vv = vim.v
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
vo.showmode = false
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
vim.o.cinoptions = "l1,:0"
vim.o.cindent = true
vim.o.foldmethod = "marker"
vim.o.foldmarker = "#region,#endregion"
local function custom_fold_text()
  local line = vim.fn.getline(vim.v.foldstart)
  local line_count = (vim.v.foldend - vim.v.foldstart)
  return string.format(" > %d lines: %s", line_count, string.gsub(line, "//%s*#region%s*", ""))
end
_G.custom_fold_text = custom_fold_text
vim.opt.foldtext = "v:lua.custom_fold_text()"
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
local function _6_()
  vim.cmd("split")
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buf)
  vim.cmd("norm G")
  local function _7_(job_id, code)
    _G.assert((nil ~= code), "Missing argument code on /home/robin/.config/nvim/init.fnl:133")
    _G.assert((nil ~= job_id), "Missing argument job_id on /home/robin/.config/nvim/init.fnl:133")
    if (code == 0) then
      if vim.api.nvim_buf_is_valid(buf) then
        return vim.api.nvim_buf_delete(buf, {})
      else
        return nil
      end
    else
      return nil
    end
  end
  vim.fn.jobstart("./build.sh", {term = true, on_exit = _7_})
  local function _10_()
    if vim.api.nvim_buf_is_valid(buf) then
      return vim.api.nvim_buf_delete(buf, {})
    else
      return nil
    end
  end
  return vim.keymap.set("n", "q", _10_, {buffer = buf, silent = true})
end
vim.api.nvim_create_user_command("Build", _6_, {})
local group = va.nvim_create_augroup("vimrc", {clear = true})
local function fnl_buf_write_post(ev)
  local file_name = tostring(va.nvim_buf_get_name(ev.buf))
  local _12_
  if windows then
    _12_ = (config_path .. "\\bin\\fennel.exe")
  else
    _12_ = (config_path .. "/bin/fennel")
  end
  local function fennel_compile_on_exit_command(completed)
    if completed then
      if (completed.code == 0) then
        local new_file = utils["change-extension"](file_name, "lua")
        local _14_, _15_ = io.open(new_file, "w+")
        if (nil ~= _14_) then
          local file = _14_
          file:write(completed.stdout)
          file:close()
          schedule_notify(((("Compiled " .. file_name) .. " to ") .. new_file))
        elseif ((_14_ == nil) and (nil ~= _15_)) then
          local err_msg = _15_
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
  vim.system({_12_, "--compile", file_name}, {text = true}, fennel_compile_on_exit_command)
  return nil
end
va.nvim_create_autocmd({"BufWritePost"}, {group = group, pattern = {"*.fnl"}, callback = fnl_buf_write_post})
require("config.plugins")
require("config.keys")
require("config.lsp")
return nil
