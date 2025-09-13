(local config (vim.fn.stdpath :config))

(fn client-supports-method [client method ?bufnr]
  (if
    (= (vim.fn.has :nvim-0.11) 1)
    (client:supports_method method ?bufnr)
    (client.supports_method method { :bufnr ?bufnr })
    ))

(vim.api.nvim_create_autocmd
  "LspAttach"
  {
    :group (vim.api.nvim_create_augroup "vimrc-lsp-attach" { :clear true })
    :callback
    (lambda [ev]
      (let [map (fn map [keys func desc ?mode] (vim.keymap.set (or ?mode "n") keys func { :buffer ev.buf :desc (.. "LSP: " desc) }))]
        (map :grn vim.lsp.buf.rename "[R]e[n]ame")
        (map :gra vim.lsp.buf.code_action "[C]ode [A]ction" [ :n :x ])
        (map :grr (. (require :telescope.builtin) :lsp_references) "[G]oto [R]eferences")
        (map :gri (. (require :telescope.builtin) :lsp_implementations) "[G]oto [I]mplementation")
        (map :grd (. (require :telescope.builtin) :lsp_definitions) "[G]oto [D]efinition")
        (map :grD vim.lsp.buf.declaration "[G]oto [D]eclaration")
        (map :gO (. (require "telescope.builtin") :lsp_document_symbols) "[D]ocument [S]ymbols")
        (map :gW (. (require "telescope.builtin") :lsp_dynamic_workspace_symbols) "[W]orkspace [S]ymbols")
        (map :grt (. (require "telescope.builtin") :lsp_type_definitions) "Type [D]efinition")
        (let [client (vim.lsp.get_client_by_id ev.data.client_id)]
         (when (and client (client-supports-method client vim.lsp.protocol.Methods.textDocument_documentHighlight ev.buf))
           (let [highlight_augroup (vim.api.nvim_create_augroup :vimrc-lsp-highlight { :clear false })]
             (vim.api.nvim_create_autocmd
               [:CursorHold :CursorHoldI]
               {
               :buffer ev.buf
               :group highlight_augroup
               :callback vim.lsp.buf.document_highlight
               })
             (vim.api.nvim_create_autocmd
               [:CursorMoved :CursorMovedI]
               {
               :buffer ev.buf
               :group highlight_augroup
               :callback vim.lsp.buf.clear_references
               })
             (vim.api.nvim_create_autocmd
               :LspDetach
               {
               :group (vim.api.nvim_create_augroup :vimrc-lsp-detach { :clear true })
               :callback (lambda [ev] (vim.lsp.buf.clear_references) (vim.api.nvim_clear_autocmds { :group :vimrc-lsp-highlight :buffer ev.buf }))
               })
             ))
         (when (and client (client-supports-method client vim.lsp.protocol.Methods.textDocument_inlayHint ev.buf))
           (map
             "<leader>th"
             (lambda []
               (vim.lsp.inlay_hint.enable (not (vim.lsp.inlay_hint.is_enabled { :bufnr ev.buf }))))
             "[T]oggle Inlay [H]ints"
             ))
         (when (and client (and
                 (not (client-supports-method client "textDocument/willSaveWaitUntil"))
                 (client-supports-method client "textDocument/formatting")))
           (vim.api.nvim_create_autocmd
             "BufWritePre"
             {
             : group
             :buffer ev.buf
             :callback
             (lambda [ev]
               (vim.lsp.buf.format { :bufnr ev.buf :id client.id :timeout_ms 1000 }))
             }))
         (vim.diagnostic.config
           {
           :severity_sort true
           :float { :border :rounded :source :if_many }
           :underline { :severity vim.diagnostic.severity.ERROR }
           :signs (or (and vim.g.have_nerd_font
                           {
                           :text {
                           vim.diagnostic.severity.ERROR "󰅚 "
                           vim.diagnostic.severity.WARN "󰀪 "
                           vim.diagnostic.severity.INFO "󰋽 "
                           vim.diagnostic.severity.HINT "󰌶 "
                           }
                           })
                      {})
           :virtual_text {
           :source :if_many
           :spacing 2
           :format (lambda [diagnostic]
                     (. {
                     vim.diagnostic.severity.ERROR diagnostic.message
                     vim.diagnostic.severity.WARN diagnostic.message
                     vim.diagnostic.severity.INFO diagnostic.message
                     vim.diagnostic.severity.HINT diagnostic.message
                     } diagnostic.severity)
                     )
           }
           })

         )) nil)})


(vim.lsp.config
  "*"
  {
  :capabilities ((. (require :blink.cmp) :get_lsp_capabilities) {} false)
  })
(local lsps ["lua_ls" "rust_analyzer" "ts_ls" "fennel_ls"])

(each [_ lsp (ipairs lsps)]
  (vim.lsp.enable lsp))

(local mini-snippets (require :mini.snippets))
; (tset mini-snippets.var_evaluators :TM_FILENAME_UPPER
;       (lambda [] (vim.fn.toupper (vim.fn.expand "%:t:r"))))
(let [gen_loader (. mini-snippets :gen_loader)]
    (mini-snippets.setup
      {
      :snippets
      [
       (gen_loader.from_file (.. config "/snippets/global.json"))
       (gen_loader.from_lang)
       ]
      })
  )
; (mini-snippets.start_lsp_server)
; ((. (require :mini.completion) :setup) {
;    :delay { :completion 0 :signature 0 :info 0 }
;    :mappings {
;      :force_twostep "<C-$>"
;      :force_fallback "<A-$>"}})

((. (require :blink.cmp) :setup)
 {
  :keymap {
   :preset :default
  }
  :appearance {
   :nerd_font_variant :mono
  :documentation {
   :auto_show true
   :auto_show_delay_ms 500
  }
  :sources {
   :default [:lsp :buffer :path :snippets]
  }
  :snippets {
   :preset :mini_snippets
  }
  :fuzzy {
   :implementation :prefer_rust_with_warning
  }
  :signature {
   :enabled true
  }
  }
 })



; (vim.cmd "set completeopt+=noselect,popup,menuone")


nil
