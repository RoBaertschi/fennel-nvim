local lsps = {"lua_ls", "rust_analyzer"}
for _, lsp in ipairs(lsps) do
  vim.lsp.enable(lsp)
end
local mini_snippets = require("mini.snippets")
local gen_loader = mini_snippets.gen_loader
mini_snippets.setup({snippets = {gen_loader.from_lang()}})
require("mini.completion").setup({delay = {completion = 0, signature = 0, info = 0}, mappings = {force_twostep = "<C-$>", force_fallback = "<A-$>"}})
local group = vim.api.nvim_create_augroup("vimrc-lsp", {clear = true})
local function _1_(ev)
  _G.assert((nil ~= ev), "Missing argument ev on C:\\Users\\Robin\\AppData\\Local\\nvim\\lua\\config\\lsp.fnl:25")
  local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
  if (not client:supports_method("textDocument/willSaveWaitUntil") and client:supports_method("textDocument/formatting")) then
    local function _2_(ev0)
      _G.assert((nil ~= ev0), "Missing argument ev on C:\\Users\\Robin\\AppData\\Local\\nvim\\lua\\config\\lsp.fnl:36")
      return vim.lsp.buf.format({bufnr = ev0.buf, id = client.id, timeout_ms = 1000})
    end
    return vim.api.nvim_create_autocmd("BufWritePre", {group = group, buffer = ev.buf, callback = _2_})
  else
    return nil
  end
end
vim.api.nvim_create_autocmd("LspAttach", {group = group, callback = _1_})
return nil
