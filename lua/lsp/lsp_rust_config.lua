local lsp_status_ok, lspconfig = pcall(require, 'lspconfig')
if not lsp_status_ok then
  return
end

local lsp_config_util_ok, util = pcall(require, 'lspconfig_util')
if not lsp_config_util_ok then
  return
end

lspconfig.rust_analyzer.setup({
    on_attach = on_attach,
    root_dir = util.root_pattern("Cargo.toml"),
    capabilities = capabilities,
    filetypes = {"rust"},
    settings = {
      ['rust_analyzer'] = {
        cargo = {
          all_Features = true,
        },
      },
    },
})
