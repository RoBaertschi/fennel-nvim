local config = vim.fn.stdpath("config")
local function client_supports_method(client, method, _3fbufnr)
  if (vim.fn.has("nvim-0.11") == 1) then
    return client:supports_method(method, _3fbufnr)
  else
    return client.supports_method(method, {bufnr = _3fbufnr})
  end
end
local function _2_(ev)
  _G.assert((nil ~= ev), "Missing argument ev on /home/robin/.config/nvim/lua/config/lsp.fnl:15")
  do
    local map
    local function map0(keys, func, desc, _3fmode)
      return vim.keymap.set((_3fmode or "n"), keys, func, {buffer = ev.buf, desc = ("LSP: " .. desc)})
    end
    map = map0
    map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
    map("gra", vim.lsp.buf.code_action, "[C]ode [A]ction", {"n", "x"})
    map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
    map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
    map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
    map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
    map("gO", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
    map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
    map("grt", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if (client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, ev.buf)) then
      local highlight_augroup = vim.api.nvim_create_augroup("vimrc-lsp-highlight", {clear = false})
      vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {buffer = ev.buf, group = highlight_augroup, callback = vim.lsp.buf.document_highlight})
      vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {buffer = ev.buf, group = highlight_augroup, callback = vim.lsp.buf.clear_references})
      local function _3_(ev0)
        _G.assert((nil ~= ev0), "Missing argument ev on /home/robin/.config/nvim/lua/config/lsp.fnl:47")
        vim.lsp.buf.clear_references()
        return vim.api.nvim_clear_autocmds({group = "vimrc-lsp-highlight", buffer = ev0.buf})
      end
      vim.api.nvim_create_autocmd("LspDetach", {group = vim.api.nvim_create_augroup("vimrc-lsp-detach", {clear = true}), callback = _3_})
    else
    end
    if (client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, ev.buf)) then
      local function _5_()
        return vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({bufnr = ev.buf}))
      end
      map("<leader>th", _5_, "[T]oggle Inlay [H]ints")
    else
    end
    if (client and (not client_supports_method(client, "textDocument/willSaveWaitUntil") and client_supports_method(client, "textDocument/formatting"))) then
      local function _7_(ev0)
        _G.assert((nil ~= ev0), "Missing argument ev on /home/robin/.config/nvim/lua/config/lsp.fnl:66")
        return vim.lsp.buf.format({bufnr = ev0.buf, id = client.id, timeout_ms = 1000})
      end
      vim.api.nvim_create_autocmd("BufWritePre", {group = group, buffer = ev.buf, callback = _7_})
    else
    end
    local function _9_(diagnostic)
      _G.assert((nil ~= diagnostic), "Missing argument diagnostic on /home/robin/.config/nvim/lua/config/lsp.fnl:87")
      return ({[vim.diagnostic.severity.ERROR] = diagnostic.message, [vim.diagnostic.severity.WARN] = diagnostic.message, [vim.diagnostic.severity.INFO] = diagnostic.message, [vim.diagnostic.severity.HINT] = diagnostic.message})[diagnostic.severity]
    end
    vim.diagnostic.config({severity_sort = true, float = {border = "rounded", source = "if_many"}, underline = {severity = vim.diagnostic.severity.ERROR}, signs = ((vim.g.have_nerd_font and {text = {[vim.diagnostic.severity.ERROR] = "\243\176\133\154 ", [vim.diagnostic.severity.WARN] = "\243\176\128\170 ", [vim.diagnostic.severity.INFO] = "\243\176\139\189 ", [vim.diagnostic.severity.HINT] = "\243\176\140\182 "}}) or {}), virtual_text = {source = "if_many", spacing = 2, format = _9_}})
  end
  return nil
end
vim.api.nvim_create_autocmd("LspAttach", {group = vim.api.nvim_create_augroup("vimrc-lsp-attach", {clear = true}), callback = _2_})
vim.lsp.config("*", {capabilities = require("blink.cmp").get_lsp_capabilities({}, false)})
local lsps = {"lua_ls", "rust_analyzer", "ts_ls", "fennel_ls"}
for _, lsp in ipairs(lsps) do
  vim.lsp.enable(lsp)
end
local mini_snippets = require("mini.snippets")
do
  local gen_loader = mini_snippets.gen_loader
  mini_snippets.setup({snippets = {gen_loader.from_file((config .. "/snippets/global.json")), gen_loader.from_lang()}})
end
require("blink.cmp").setup({keymap = {preset = "default"}, appearance = {nerd_font_variant = "mono", documentation = {auto_show = true, auto_show_delay_ms = 500}, sources = {default = {"lsp", "buffer", "path", "snippets"}}, snippets = {preset = "mini_snippets"}, fuzzy = {implementation = "prefer_rust_with_warning"}, signature = {enabled = true}}})
return nil
