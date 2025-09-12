local config = vim.fn.stdpath("config")
local group = vim.api.nvim_create_augroup("vimrc-lsp", {clear = true})
local function _1_(ev)
  _G.assert((nil ~= ev), "Missing argument ev on C:\\Users\\rtmba\\AppData\\Local\\nvim\\lua\\config\\lsp.fnl:9")
  print("hi")
  do
    local map
    local function _2_(keys, func, desc)
      _G.assert((nil ~= desc), "Missing argument desc on C:\\Users\\rtmba\\AppData\\Local\\nvim\\lua\\config\\lsp.fnl:11")
      _G.assert((nil ~= func), "Missing argument func on C:\\Users\\rtmba\\AppData\\Local\\nvim\\lua\\config\\lsp.fnl:11")
      _G.assert((nil ~= keys), "Missing argument keys on C:\\Users\\rtmba\\AppData\\Local\\nvim\\lua\\config\\lsp.fnl:11")
      return vim.keymap.set("n", keys, func, {buffer = ev.buf, desc = ("LSP: " .. desc)})
    end
    map = _2_
    map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
    map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
    map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
    map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
    map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
    map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
    map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
    map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
    map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
  end
  local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
  if (not client:supports_method("textDocument/willSaveWaitUntil") and client:supports_method("textDocument/formatting")) then
    local function _3_(ev0)
      _G.assert((nil ~= ev0), "Missing argument ev on C:\\Users\\rtmba\\AppData\\Local\\nvim\\lua\\config\\lsp.fnl:32")
      return vim.lsp.buf.format({bufnr = ev0.buf, id = client.id, timeout_ms = 1000})
    end
    return vim.api.nvim_create_autocmd("BufWritePre", {group = group, buffer = ev.buf, callback = _3_})
  else
    return nil
  end
end
vim.api.nvim_create_autocmd("LspAttach", {group = group, callback = _1_})
local lsps = {"lua_ls", "rust_analyzer", "ts_ls"}
for _, lsp in ipairs(lsps) do
  vim.lsp.enable(lsp)
end
local mini_snippets = require("mini.snippets")
do
  local gen_loader = mini_snippets.gen_loader
  mini_snippets.setup({snippets = {gen_loader.from_file((config .. "/snippets/global.json")), gen_loader.from_lang()}})
end
require("mini.completion").setup({delay = {completion = 0, signature = 0, info = 0}, mappings = {force_twostep = "<C-$>", force_fallback = "<A-$>"}})
return nil
