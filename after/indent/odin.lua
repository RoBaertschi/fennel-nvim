vim.opt_local.cinoptions:append("c0")
vim.opt_local.comments = "s0:/*,ex:*/,://"
return vim.opt_local.formatoptions:remove({"r", "o"})
