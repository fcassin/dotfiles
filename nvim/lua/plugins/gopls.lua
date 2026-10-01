return {
  "neovim/nvim-lspconfig",
  opts = {
    setup = {
      gopls = function(_, opts)
        -- Tell gopls we do not support dynamic file watching. Neovim's
        -- built-in watcher does not reliably cover files outside the
        -- buffer's own root_dir (e.g. other go.work member modules), so
        -- edits to those files never reach gopls. Disabling the capability
        -- makes gopls fall back to its own internal watcher, which does
        -- cover the full go.work workspace.
        opts.capabilities = opts.capabilities or {}
        opts.capabilities.workspace = opts.capabilities.workspace or {}
        opts.capabilities.workspace.didChangeWatchedFiles = { dynamicRegistration = false }

        -- workaround for gopls not supporting semanticTokensProvider
        -- https://github.com/golang/go/issues/54531#issuecomment-1464982242
        Snacks.util.lsp.on({ name = "gopls" }, function(_, client)
          if
            client.config
            and client.config.init_options
            and client.config.init_options.semanticTokens
            and not client.server_capabilities.semanticTokensProvider
          then
            local semantic = client.config.capabilities.textDocument.semanticTokens
            client.server_capabilities.semanticTokensProvider = {
              full = true,
              legend = {
                tokenTypes = semantic.tokenTypes,
                tokenModifiers = semantic.tokenModifiers,
              },
              range = true,
            }
          end
        end)
        -- end workaround
      end,
    },
  },
}
