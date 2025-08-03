(local lsps ["lua_ls"])

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


; (local group (vim.api.nvim_create_augroup "vimrc-lsp" { :clear true }))
; (vim.api.nvim_create_autocmd
;   "LspAttach"
;   {
;     : group
;     :callback
;     (lambda [ev]
;       (let [client (assert (vim.lsp.get_client_by_id ev.data.client_id))]
;         (when (client:supports_method "textDocument/completion")
;           (vim.lsp.completion.enable true client.id ev.buf { :autotrigger true }))
;         (when (and 
;                 (not (client:supports_method "textDocument/willSaveWaitUntil"))
;                 (client:supports_method "textDocument/formatting"))
;           (vim.api.nvim_create_autocmd
;             "BufWritePre"
;             {
;             : group
;             :buffer ev.buf
;             :callback
;             (lambda [ev]
;               (vim.lsp.buf.format { :bufnr ev.buf :id client.id :timeout_ms 1000 }))
;             }))))
;   }
;   )

nil
