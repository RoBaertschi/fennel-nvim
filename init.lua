local vo = vim.opt
local vg = vim.g
local va = vim.api
local sysname = vim.loop.os_uname().sysname
local windows = (sysname == "Windows_NT")
local config_path = vim.fn.stdpath("config")
local function change_extension(file_path, new_ext)
  local pattern = "%.%w+$"
  if file_path:match(pattern) then
    return file_path:gsub(pattern, ("." .. new_ext))
  else
    return (file_path .. new_ext)
  end
end
vg["mapleader"] = " "
vg["maplocalleader"] = " "
vg["have_nerd_font"] = true
vo["number"] = true
vo["relativenumber"] = true
vo["mouse"] = "a"
vo["showmode"] = true
local function _2_()
  vo["clipboard"] = "unnamedplus"
  return nil
end
vim.schedule(_2_)
vo["breakindent"] = true
vo["undofile"] = true
vo["ignorecase"] = true
vo["smartcase"] = true
vo["signcolumn"] = "yes"
vo["updatetime"] = 250
vo["timeoutlen"] = 300
vo["splitright"] = true
vo["splitbelow"] = true
vo["list"] = true
vo["listchars"] = {tab = "\194\187 ", trail = "\194\183", nbsp = "\226\144\163"}
vo["inccommand"] = "split"
vo["cursorline"] = true
vo["scrolloff"] = 10
vg["c_syntax_for_h"] = 1
vo["tabstop"] = 4
vo["softtabstop"] = 4
vo["shiftwidth"] = 4
vo["expandtab"] = true
vo["termguicolors"] = true
vo["guifont"] = "JetBrainsMono NF"
if vg.neovide then
  vg["neovide_cursor_animation_length"] = 0
else
end
local function schedule_notify(message, level_3f)
  local function _4_()
    return vim.notify(message, level)
  end
  return vim.schedule(_4_)
end
local group = va.nvim_create_augroup("vimrc", {clear = true})
local function fnl_buf_write_post(ev)
  local file_name = tostring(va.nvim_buf_get_name(ev.buf))
  local _5_
  if windows then
    _5_ = (config_path .. "\\bin\\fennel.exe")
  else
    _5_ = (config_path .. "bin/fennel")
  end
  local function fennel_compile_on_exit_command(completed)
    if completed then
      if (completed.code == 0) then
        local new_file = change_extension(file_name, "lua")
        local _7_, _8_ = io.open(new_file, "w+")
        if (nil ~= _7_) then
          local file = _7_
          file:write(completed.stdout)
          file:close()
          schedule_notify(((("Compiled " .. file_name) .. " to ") .. new_file))
        elseif ((_7_ == nil) and (nil ~= _8_)) then
          local err_msg = _8_
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
  vim.system({_5_, "--compile", file_name}, {text = true}, fennel_compile_on_exit_command)
  return nil
end
va.nvim_create_autocmd({"BufWritePost"}, {group = group, pattern = {"*.fnl"}, callback = fnl_buf_write_post})
require("config.plugins")
require("config.keys")
require("config.lsp")
return nil
