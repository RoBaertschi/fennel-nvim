(local data (vim.fn.stdpath :data))
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

(fn add-plugin [name src branch?] defer_fn
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

(vim.cmd "packl!")

(vim.cmd "colorscheme tokyonight-night")

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
    ))

(nvim-treesitter.install install)


(local group (vim.api.nvim_create_augroup "vimrc-treesitter" { :clear true }))
(vim.api.nvim_create_autocmd
  "User"
  {
  :pattern "TSUpdate"
  : group
  :callback
  (lambda [args]
    (tset (require :nvim-treesitter.parsers)
          :odin
          {
          :install_info {
            :url "https://github.com/RoBaertschi/tree-sitter-odin"
            :queries "queries"
            :branch "master"
          }
          }))
  }
  )
(vim.api.nvim_create_autocmd
  "FileType"
  {
  : group
  :callback (lambda
              [args]

              (let [
                    ok (pcall vim.treesitter.start args.buf)
                    setup (lambda []
                            (tset vim.bo :indentexpr "v:lua.require('nvim-treesitter').indentexpr()")
                            (tset vim.wo :foldtext "v:lua.require('nvim-treesitter').foldtext()")
                            (tset vim.wo :foldmethod "expr")
                            (tset vim.wo :foldexpr "v:lua.require('nvim-treesitter').foldexpr()")
                            (tset vim.wo :foldlevel 99)
                            (tset vim.opt :foldlevelstart -1)
                            (tset vim.opt :foldnestmax 99)
                            )

                    ]
                (if ok (do (setup))
                    (let [a (require :nvim-treesitter.async)]
                      (a.arun
                        (lambda []
                          (let
                            [installing ((. (require :nvim-treesitter.install) :install) (vim.treesitter.language.get_lang args.match))]

                            (when (pcall a.await installing)
                              (vim.treesitter.start args.buf)
                              (setup)
                              )
                            )))
                      )
                    )
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
((. (require :mini.ai) :setup) {})
(local statusline (require :mini.statusline))
(statusline.setup { :use_icons true })
(tset statusline :section_location (lambda [] "%2l:%-2v"))

; oil
((. (require :oil) :setup) {})
nil
