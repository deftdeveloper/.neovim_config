plugins = {
    {
      "williamboman/mason.nvim",
      opts = {
        ensure_installed = {
          "rust_analyzer",
        },
      },
    },
		{
     "neovim/nvim-lspconfig",
     config = function()
       require "lsp.lsp_rust_config"
     end,
    },

}

return plugins
