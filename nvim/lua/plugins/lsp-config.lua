return {
    {
        "williamboman/mason.nvim",
        lazy = false,
        config = function()
            require("mason").setup()
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        lazy = false,
        opts = {
            auto_install = true,
        },
    },
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        config = function()
            local cmp_nvim_lsp = require("cmp_nvim_lsp")
            local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                cmp_nvim_lsp.default_capabilities()
            )

            -- Add folding capability
            -- capabilities.textDocument.foldingRange = {
            --     dynamicRegistration = false,
            --     lineFoldingOnly = true,
            -- }

            local lspconfig = require("lspconfig")
            lspconfig.tailwindcss.setup({
                capabilities = capabilities,
            })
            lspconfig.hls.setup {
                filetypes = { 'haskell', 'lhaskell' },
                settings = {
                    haskell = {
                        formattingProvider = "ormolu", -- or "fourmolu" / "stylish-haskell"
                        plugin = {
                            hlint = { globalOn = true },
                        },
                    },
                },
            }
            lspconfig.lua_ls.setup({
                capabilities = capabilities,
            })
            lspconfig.pyright.setup({
                capabilities = capabilities,
            })

            -- Diagnostic virtual text setup
            vim.diagnostic.config({
                virtual_text = {
                    prefix = "󱈸", -- change to whatever you like
                    spacing = 2,
                },
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
            })

            vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
            vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
            vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
            vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
            -- vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, {})
        end,
    },
}


-- return {
--     {
--         "williamboman/mason.nvim",
--         lazy = false,
--         config = function()
--             require("mason").setup()
--         end,
--     },
--     {
--         "williamboman/mason-lspconfig.nvim",
--         lazy = false,
--         opts = {
--             auto_install = true,
--         },
--     },
--     {
--         "neovim/nvim-lspconfig",
--         lazy = false,
--         config = function()
--             local cmp_nvim_lsp = require("cmp_nvim_lsp")
--             local capabilities = vim.tbl_deep_extend(
--                 "force",
--                 {},
--                 vim.lsp.protocol.make_client_capabilities(),
--                 cmp_nvim_lsp.default_capabilities()
--             )
--
--             local lspconfig = require("lspconfig")
--
--             lspconfig.tailwindcss.setup({
--                 capabilities = capabilities,
--             })
--             lspconfig.lua_ls.setup({
--                 capabilities = capabilities,
--             })
--             lspconfig.pyright.setup({})
--         -- Diagnostic virtual text setup
--         vim.diagnostic.config({
--           virtual_text = {
--             prefix = "󱈸", -- change to whatever you like
--             spacing = 2,
--           },
--           signs = true,
--           underline = true,
--           update_in_insert = false,
--           severity_sort = true,
--         })
--             vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
--             vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
--             vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
--             vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
--             vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
--             -- vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, {})
--         end,
--     },
-- }
