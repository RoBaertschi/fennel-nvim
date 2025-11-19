(local data (vim.fn.stdpath :data))
(local config (vim.fn.stdpath :config))
(local loop (or vim.uv vim.loop))
(local plugins [])
(local pack-dir (.. data "/site/pack"))

(fn mkdir [dir]
  (when (not (loop.fs_stat dir))
    (let [d (vim.schedule_wrap (lambda [] vim.fn.mkdir "p" dir) 0)]
      (d)
      ))
  nil)

(mkdir pack-dir)

(fn plugin-path [plugin]
  (.. (.. (.. (.. pack-dir "/") plugin) "/start/") plugin))

(fn installed [plugin]
  (if (loop.fs_stat (plugin-path plugin))
      true
      false))

(fn add-plugin-to-rtp [plugin]
  (assert (installed plugin))
  (vim.opt.rtp:append (plugin-path plugin)))

(fn clone-plugin [src to branch?]
  (mkdir to)
  (let [result
         (let [sync-output
                (vim.system [:git :clone
                                  (if branch?
                                      (.. "--branch=" branch?)
                                      nil)
                                  src to])]
           (sync-output:wait)
           )]
    (if (= result.code 0) nil result)
    ))

(fn add-plugin [name src branch?]
  (when (not (installed name))
    (case (clone-plugin src (plugin-path name) (or branch? nil))
      failed (error (vim.inspect failed))
      nil nil)))


(add-plugin :tokyonight "https://github.com/folke/tokyonight.nvim.git")
(add-plugin :nvim-treesitter "https://github.com/nvim-treesitter/nvim-treesitter" :main)
(add-plugin :which-key "https://github.com/folke/which-key.nvim")
(add-plugin :mason "https://github.com/mason-org/mason.nvim")
(add-plugin :lsp-config "https://github.com/neovim/nvim-lspconfig")
(add-plugin :oil "https://github.com/stevearc/oil.nvim")

; telescope
(add-plugin :plenary "https://github.com/nvim-lua/plenary.nvim")
(add-plugin :nvim-web-devicons "https://github.com/nvim-tree/nvim-web-devicons")
(add-plugin :telescope-ui-select "https://github.com/nvim-telescope/telescope-ui-select.nvim")
(add-plugin :telescope "https://github.com/nvim-telescope/telescope.nvim")

(add-plugin :mini "https://github.com/echasnovski/mini.nvim")
(add-plugin :blink.cmp "https://github.com/saghen/blink.cmp" :v1.7.0)
(add-plugin :conform "https://github.com/stevearc/conform.nvim")
(add-plugin :todo-comments "https://github.com/folke/todo-comments.nvim")
(add-plugin :rivial "https://github.com/robaertschi/rivial")

(vim.cmd "packl!")

(vim.cmd "colorscheme rivial")


(local group (vim.api.nvim_create_augroup "vimrc-treesitter" { :clear true }))
(vim.api.nvim_create_autocmd
  "User"
  {
  :pattern "TSUpdate"
  : group
  :callback
  (lambda [args]
    (tset (. (require :nvim-treesitter.parsers) :odin)
          :install_info {
            :url "https://github.com/RoBaertschi/tree-sitter-odin"
            :branch "master"
          })
    (tset (require :nvim-treesitter.parsers)
          :sjson {
           :install_info {
            :url "https://github.com/RoBaertschi/tree-sitter-sjson"
            :revision "c9b7e606de8ec376a4641e7db1ca5722d5afff2d"
           }
           :maintainers [ "@RoBaertschi" ]
           :tier 2
          }))
  }
  )

(local nvim-treesitter (require :nvim-treesitter))
(nvim-treesitter.setup {})
(vim.cmd "TSUpdate")

(local to_install [:bash :c :diff :html
                         :lua :luadoc :markdown
                         :markdown_inline :query :vim
                         :vimdoc])

(let [installed (nvim-treesitter.get_installed) install {}]
  (each [_ value (ipairs to_install)]
    (var already-installed false)
    (each [_ found (ipairs installed)]
      (when found (set already-installed true)))
    (when (not already-installed)
      (table.insert install value))
    )
  (nvim-treesitter.install install))

(vim.api.nvim_create_autocmd
  "FileType"
  {
  : group
  :callback (lambda
              [args]

              (let [
                    attach (lambda [buf language]
                             (if
                               (not (vim.treesitter.language.add language))
                               false
                               (let []
                                 (vim.treesitter.start buf language)
                                 (tset vim.bo :indentexpr "v:lua.require('nvim-treesitter').indentexpr()")
                                 (tset vim.wo :foldtext "v:lua.require('nvim-treesitter').foldtext()")
                                 (tset vim.wo :foldmethod "expr")
                                 (tset vim.wo :foldexpr "v:lua.require('nvim-treesitter').foldexpr()")
                                 (tset vim.wo :foldlevel 99)
                                 (tset vim.opt :foldlevelstart -1)
                                 (tset vim.opt :foldnestmax 99)
                                 true
                               )
                             ))
                    language (vim.treesitter.language.get_lang args.match)

                    ]
                (when (and language ; (~= language :odin)
                           true)
                  (when (not (attach args.buf language))
                    (let
                      [installing ((. (require :nvim-treesitter.install) :install) language)]
                      (installing:await
                        (lambda [] (attach args.buf language))))))
                ) nil
              )
  })

; Which key

(local which-key (require :which-key))
(which-key.setup {})
(vim.keymap.set "n" "<leader>?" (lambda [] (which-key.show {:global false})))

; Telescope
(local telescope (require :telescope))
(telescope.setup {
                 :extensions {
                   :ui-select [ ((. (require :telescope.themes) :get_dropdown)) ]
                 }
                 :defaults {
                   :file_ignore_patterns {}
                 }
                 })

(telescope.load_extension :ui-select)

; Mason
(local mason (require :mason))
(mason.setup {})

; mini

((. (require :mini.ai) :setup) { :n_lines 500 })
((. (require :mini.surround) :setup) {})
(local statusline (require :mini.statusline))
(statusline.setup { :use_icons true })
(tset statusline :section_location (lambda [] "%2l:%-2v"))

; oil
((. (require :oil) :setup) {
                            :buf_options {
                             :buflisted true
                            }
                            :view_options {
                             :show_hidden true
                            }
                           })

; conform.nvim
((. (require :conform) :setup) {:notify_on_error false
                                :format_on_save
                                (lambda [bufnr]
                                  (let [disable_filetype { :c true :cpp true }]
                                    (if (. disable_filetype (. (. vim.bo bufnr) :filetype)) nil {:timeout_ms 500 :lsp_format :fallback})))
                                :formatters_by_ft { :lua [ :stylua ] }})

(vim.keymap.set :n "<leader>f" (lambda [] ((. (require :conform) :format) { :async true :lsp_format :fallback })))

((. (require :todo-comments) :setup)
 {
  :signs false
  :highlight {
   :pattern [ ".*<(KEYWORDS)\\s*:" ".*<(KEYWORDS)\\s*\\(\\w*\\)\\s*:" ]
   :keyword :bg
  }
  :search {
   :pattern "\\b(KEYWORDS)\\s*(\\(\\w*\\))?\\s*:"
  }
 })

nil
