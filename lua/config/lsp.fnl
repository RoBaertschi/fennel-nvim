(local lsps ["lua_ls" "rust_analyzer" "ts_ls"])

(each [_ lsp (ipairs lsps)]
  (vim.lsp.enable lsp))

(local mini-snippets (require :mini.snippets))
(local gen_loader mini-snippets.gen_loader)
(mini-snippets.setup { :snippets [(gen_loader.from_lang)] })
((. (require :mini.completion) :setup) {
   :delay { :completion 0 :signature 0 :info 0 }
   :mappings {
     :force_twostep "<C-$>"
     :force_fallback "<A-$>"}})


; (vim.cmd "set completeopt+=noselect,popup,menuone")


(local group (vim.api.nvim_create_augroup "vimrc-lsp" { :clear true }))
(vim.api.nvim_create_autocmd
  "LspAttach"
  {
    : group
    :callback
    (lambda [ev]
      (let [client (assert (vim.lsp.get_client_by_id ev.data.client_id))]
        (let [map (lambda [keys func desc] (vim.keymap.set :n keys func { :buffer ev.buf :desc (.. "LSP: " desc) }))]
            (map :gd (. (require :telescope.builtin) :lsp_definitions) "[G]oto [D]efinition")
            (map :gr (. (require :telescope.builtin) :lsp_references) "[G]oto [R]eferences")
            (map :gI (. (require :telescope.builtin) :lsp_implementations) "[G]oto [I]mplementation")
            (map "<leader>D" (. (require "telescope.builtin") :lsp_type_definitions) "Type [D]efinition")
            (map "<leader>ds" (. (require "telescope.builtin") :lsp_document_symbols) "[D]ocument [S]ymbols")
            (map "<leader>ws" (. (require "telescope.builtin") :lsp_dynamic_workspace_symbols) "[W]orkspace [S]ymbols")
            (map "<leader>rn" vim.lsp.buf.rename "[R]e[n]ame")
            (map "<leader>ca" vim.lsp.buf.code_action "[C]ode [A]ction")
            (map "gD" vim.lsp.buf.declaration "[G]oto [D]eclaration")
            )
        (when (and
                (not (client:supports_method "textDocument/willSaveWaitUntil"))
                (client:supports_method "textDocument/formatting"))
          (vim.api.nvim_create_autocmd
            "BufWritePre"
            {
            : group
            :buffer ev.buf
            :callback
            (lambda [ev]
              (vim.lsp.buf.format { :bufnr ev.buf :id client.id :timeout_ms 1000 }))
            }))))
  }
  )

nil
