-----------------------------------------------------------
-- Plugin manager configuration file
-----------------------------------------------------------

-- Plugin manager: lazy.nvim
-- URL: https://github.com/folke/lazy.nvim

-- For information about installed plugins see the README:
-- neovim-lua/README.md
-- https://github.com/brainfucksec/neovim-lua#readme

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Use a protected call so we don't error out on first use
local status_ok, lazy = pcall(require, "lazy")
if not status_ok then
	return
end

-- Start setup
lazy.setup({
	spec = {

		-- Colorscheme:
		-- The colorscheme should be available when starting Neovim.
		{
			"navarasu/onedark.nvim",
			lazy = false, -- make sure we load this during startup if it is your main colorscheme
			priority = 1000, -- make sure to load this before all the other start plugins
		},

		-- other colorschemes:
		{ "tanvirtin/monokai.nvim", lazy = true },
		{ "https://github.com/rose-pine/neovim", name = "rose-pine", lazy = true },

		-- Icons
		{ "kyazdani42/nvim-web-devicons", lazy = true },

		-- Dashboard (start screen)
		{
			"goolord/alpha-nvim",
			dependencies = { "kyazdani42/nvim-web-devicons" },
		},

		-- Git labels
		{
			"lewis6991/gitsigns.nvim",
			lazy = true,
			dependencies = {
				"nvim-lua/plenary.nvim",
				"kyazdani42/nvim-web-devicons",
			},
			config = function()
				require("gitsigns").setup({})
			end,
		},

		-- File explorer
		{
			"kyazdani42/nvim-tree.lua",
			dependencies = { "kyazdani42/nvim-web-devicons" },
		},

		-- Statusline
		{
			"freddiehaddad/feline.nvim",
			dependencies = {
				"kyazdani42/nvim-web-devicons",
				"lewis6991/gitsigns.nvim",
			},
		},

		-- Treesitter
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			opts = function(_, opts)
				if type(opts.ensure_installed) == "table" then
					vim.list_extend(opts.ensure_installed, { "ron", "rust", "toml" })
				end
			end,
		},

    {
      "simrat39/rust-tools.nvim",
      lazy = true,
      opts = function()
        local ok, mason_registry = pcall(require, "mason-registry")
        local adapter ---@type any
        if ok then
          -- rust tools configuration for debugging support
          local codelldb = mason_registry.get_package("codelldb")
          local extension_path = codelldb:get_install_path() .. "/extension/"
          local codelldb_path = extension_path .. "adapter/codelldb"
          local liblldb_path = ""
          if vim.loop.os_uname().sysname:find("Windows") then
            liblldb_path = extension_path .. "lldb\\bin\\liblldb.dll"
          elseif vim.fn.has("mac") == 1 then
            liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"
          else
            liblldb_path = extension_path .. "lldb/lib/liblldb.so"
          end
          adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path)
        end
        return {
          dap = {
            adapter = adapter,
          },
          tools = {
            on_initialized = function()
              vim.cmd([[
                    augroup RustLSP
                      autocmd CursorHold                      *.rs silent! lua vim.lsp.buf.document_highlight()
                      autocmd CursorMoved,InsertEnter         *.rs silent! lua vim.lsp.buf.clear_references()
                      autocmd BufEnter,CursorHold,InsertLeave *.rs silent! lua vim.lsp.codelens.refresh()
                    augroup END
                  ]])
            end,
          },
        }
      end,
      config = function() end,
    },

		-- Indent line
		{ "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },

		-- Tag viewer
		{ "preservim/tagbar" },

		-- Autopair
		{
			"windwp/nvim-autopairs",
			event = "InsertEnter",
			config = function()
				require("nvim-autopairs").setup({})
			end,
		},
		-- LSP
		{
			"neovim/nvim-lspconfig",
			--config = function()
			--  require "plugins.config.lspconfig"
			--end,
		},

		-- Autocomplete
		{
			"hrsh7th/nvim-cmp",
			-- load cmp on InsertEnter
			event = "InsertEnter",
			-- these dependencies will only be loaded when cmp loads
			-- dependencies are always lazy-loaded unless specified otherwise
      --
      {
        "Saecki/crates.nvim",
        event = { "BufRead Cargo.toml" },
        opts = {src = {cmp = { enabled = true }}},
      },
			dependencies = {
				"L3MON4D3/LuaSnip",
				"hrsh7th/cmp-nvim-lsp",
				"hrsh7th/cmp-path",
				"hrsh7th/cmp-buffer",
				"saadparwaiz1/cmp_luasnip",
				"Saecki/crates.nvim",
			},
			event = { "BufRead Cargo.toml" },
			opts = {
				src = {
					cmp = { enabled = true },
				},
			},
      opts = function(_, opts)
          local cmp = require("cmp")
          opts.sources = cmp.config.sources(vim.list_extend(opts.sources, {
            { name = "crates" },
          }))
        end
		},
		{
			"nativerv/cyrillic.nvim",
			event = { "VeryLazy" },
			config = function()
				require("cyrillic").setup({
					no_cyrillic_abbrev = false,
				})
			end,
		},
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Ensure mason installs the server
        rust_analyzer = {
          keys = {
            { "K", "<cmd>RustHoverActions<cr>", desc = "Hover Actions (Rust)" },
            { "<leader>cR", "<cmd>RustCodeAction<cr>", desc = "Code Action (Rust)" },
            { "<leader>dr", "<cmd>RustDebuggables<cr>", desc = "Run Debuggables (Rust)" },
          },
          settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                runBuildScripts = true,
              },
              -- Add clippy lints for Rust.
              checkOnSave = {
                allFeatures = true,
                command = "clippy",
                extraArgs = { "--no-deps" },
              },
              procMacro = {
                enable = true,
                ignored = {
                  ["async-trait"] = { "async_trait" },
                  ["napi-derive"] = { "napi" },
                  ["async-recursion"] = { "async_recursion" },
                },
              },
            },
          },
        },
        taplo = {
          keys = {
            {
              "K",
              function()
                if vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
                  require("crates").show_popup()
                else
                  vim.lsp.buf.hover()
                end
              end,
              desc = "Show Crate Documentation",
            },
          },
        },
      },
      setup = {
        rust_analyzer = function(_, opts)
          local rust_tools_opts = require("lazyvim.util").opts("rust-tools.nvim")
          require("rust-tools").setup(vim.tbl_deep_extend("force", rust_tools_opts or {}, { server = opts }))
          return true
        end,
      },
    },
  },
  {
    "rouge8/neotest-rust",
  }

})
