(local vo (. vim :opt))
(local vg (. vim :g))
(local va (. vim :api))
(local sysname (. (vim.loop.os_uname) :sysname))
(local windows (= sysname "Windows_NT"))
(local config-path (vim.fn.stdpath "config"))

(fn change-extension [file-path new-ext]
  (let [pattern "%.%w+$"]
    (if (file-path:match pattern)
        (file-path:gsub pattern (.. "." new-ext))
        (.. file-path new-ext)
        )))

(tset vg :mapleader " ")
(tset vg :maplocalleader " ")

(tset vg :have_nerd_font true)

(tset vo :number true)
(tset vo :relativenumber true)

(tset vo :mouse "a")

(tset vo :showmode true) ; maybe disable this at some point

(vim.schedule (lambda [] (tset vo :clipboard "unnamedplus")))

(tset vo :breakindent true)

; Save undo history
(tset vo :undofile true)

; Case-insensitive searching UNLESS \C or one or more capital letters in the search term
(tset vo :ignorecase true)
(tset vo :smartcase true)
l
; Keep signcolumn on by default
(tset vo :signcolumn "yes")

; Decrease update time
(tset vo :updatetime 250)

; Decrease mapped sequence wait time
; Displays which-key popup sooner
(tset vo :timeoutlen 300)

; Configure how new splits should be opened
(tset vo :splitright true)
(tset vo :splitbelow true)

; Sets how neovim will display certain whitespace characters in the editor.
;  See `:help 'list'`
;  and `:help 'listchars'`
(tset vo :list true)
(tset vo :listchars { :tab "» " :trail "·" :nbsp "␣" })

; Preview substitutions live, as you type!
(tset vo :inccommand "split")

; Show which line your cursor is on
(tset vo :cursorline true)

; Minimal number of screen lines to keep above and below the cursor.
(tset vo :scrolloff 10)

; (tset vg :c_syntax_for_h 1)

(tset vo :tabstop 4)
(tset vo :softtabstop 4)
(tset vo :shiftwidth 4)
(tset vo :expandtab true)

(tset vo :termguicolors true)

(tset vo :guifont "JetBrainsMono NF")

(when (. vg :neovide) (tset vg :neovide_cursor_animation_length 0))

(fn schedule-notify [message level?]
  (vim.schedule (lambda []
                  (vim.notify message level))))

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
                          (let [new-file (change-extension file-name "lua")]
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
