(local utils (require :config.utils))

(local vo (. vim :opt))
(local vv vim.v)
(local vg (. vim :g))
(local va (. vim :api))
(local sysname (. (vim.loop.os_uname) :sysname))
(local windows (= sysname "Windows_NT"))
(local config-path (vim.fn.stdpath "config"))

(set vg.mapleader " ")
(set vg.maplocalleader " ")

(set vg.have_nerd_font true)

(set vo.number true)
(set vo.relativenumber true)

(set vo.mouse "a")

(set vo.showmode false)


; Fix clipboard flicker on terminals that support osc52 (ansi terminal paste controls)
(if (~= (vim.fn.has :linux) 0) (set vg.clipboard "wl-copy"))

(vim.schedule (lambda [] (set vo.clipboard "unnamedplus")))

(set vo.breakindent true)

; Save undo history
(set vo.undofile true)

; Case-insensitive searching UNLESS \C or one or more capital letters in the search term
(set vo.ignorecase true)
(set vo.smartcase true)

; Keep signcolumn on by default
(set vo.signcolumn "yes")

; Decrease update time
(set vo.updatetime 250)

; Decrease mapped sequence wait time
; Displays which-key popup sooner
(set vo.timeoutlen 300)

; Configure how new splits should be opened
(set vo.splitright true)
(set vo.splitbelow true)

; Sets how neovim will display certain whitespace characters in the editor.
;  See `:help 'list'`
;  and `:help 'listchars'`
(set vo.list true)
(set vo.listchars {:nbsp "␣" :tab "» " :trail "·"})

; Preview substitutions live, as you type!
(set vo.inccommand "split")

; Allos block edits to go past new lines
(set vo.virtualedit "block")

; Show which line your cursor is on
(set vo.cursorline true)

; Minimal number of screen lines to keep above and below the cursor.
(set vo.scrolloff 10)

(set vg.c_syntax_for_h 1)

(set vo.tabstop 4)
(set vo.softtabstop 4)
(set vo.shiftwidth 4)
(set vo.expandtab true)
(set vo.formatoptions "rqnl1j")

(set vo.termguicolors true)

(set vo.guifont "JetBrainsMono NF")

(when (. vg :neovide) (set vg.neovide_cursor_animation_length 0))

(set vim.o.foldmethod "foldmarker")
(set vim.o.foldmarker "#region,#endregion")

(fn custom-fold-text []
  (let
    [
     line (vim.fn.getline vim.v.foldstart)
     line_count (- vim.v.foldend vim.v.foldstart)
     ] (string.format " > %d lines: %s" line_count (string.gsub line "//%s*#region%s*" ""))))
(set _G.custom_fold_text custom-fold-text)

(set vim.opt.foldtext "v:lua.custom_fold_text()")

(fn schedule-notify [message level?]
  (vim.schedule (lambda []
                  (vim.notify message level?))))

(local gr (vim.api.nvim_create_augroup "vimrc-default-group" {}))
(vim.api.nvim_create_autocmd "FileType" {
                              :group gr
                              :pattern nil
                              :callback (lambda []
                                          (vim.cmd
                                            "setlocal formatoptions-=c formatoptions-=o")
                                          nil)
                              :desc "Proper 'formatoptions'"
                             })

(vim.filetype.add
  {
   :extension {
    :sjson :sjson
   }
  })

; Setup autocmd

(local group (va.nvim_create_augroup "vimrc" { :clear true }))

(va.nvim_create_autocmd
  ["BufWritePost"]
  {
    : group
    :pattern ["*.fnl"]
    :callback (fn fnl-buf-write-post [ev]
                (let [file-name (tostring (va.nvim_buf_get_name ev.buf))]
                  (vim.system
                    [
                     (if windows
                         (.. config-path "\\bin\\fennel.exe")
                         (.. config-path "/bin/fennel"))
                     "--compile"
                     file-name]
                    { :text true }
                    (fn fennel-compile-on-exit-command [completed]
                      (when completed
                        (if
                          (= completed.code 0)
                          (let [new-file (utils.change-extension file-name "lua")]
                            (case (io.open new-file "w+")
                              file (do
                                  (file:write completed.stdout)
                                  (file:close)
                                  (schedule-notify
                                    (.. (.. (.. "Compiled " file-name) " to ") new-file))
                                  )
                              (nil err-msg) (schedule-notify
                                              (..
                                                (..
                                                  (..
                                                    "Could not open file " new-file)
                                                  ": ") err-msg))))
                            (schedule-notify (..
                                          (.. "stdout:\n" completed.stdout)
                                          (.. "stderr:\n" completed.stderr))
                                        vim.log.levels.ERROR)
                             )) nil)
    ) nil)
  )})

(require "config.plugins")
(require "config.keys")
(require "config.lsp")
nil
