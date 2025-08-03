local lsps = {"lua_ls"}
for _, lsp in ipairs(lsps) do
  vim.lsp.enable(lsp)
end
local mini_snippets = require("mini.snippets")
local gen_loader = mini_snippets.gen_loader
mini_snippets.setup({snippets = {gen_loader.from_lang()}})
require("mini.completion").setup({delay = {completion = 0, signature = 0, info = 0}, mappings = {force_twostep = "<C-$>", force_fallback = "<A-$>"}})
return nil
