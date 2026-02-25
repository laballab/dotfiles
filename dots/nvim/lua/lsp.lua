-- lsp setup

local function has(mod)
  local ok, m = pcall(require, mod)
  if ok then return m end
end

if type(vim.lsp) ~= 'table'
or type(vim.lsp.enable) ~= 'function'
or type(vim.lsp.config) ~= 'table'
then return end

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local map = function(lhs, rhs)
      vim.keymap.set('n', lhs, rhs, { buffer = args.buf })
    end
    map('gd', vim.lsp.buf.definition)
    map('gr', vim.lsp.buf.references)
    map('K', vim.lsp.buf.hover)
    map('<leader>rn', vim.lsp.buf.rename)
    map('<leader>ca', vim.lsp.buf.code_action)
    map('[d', vim.diagnostic.goto_prev)
    map(']d', vim.diagnostic.goto_next)
  end,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_lsp = has('cmp_nvim_lsp')
if cmp_lsp and type(cmp_lsp.default_capabilities) == 'function' then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

local function enable(server, overrides)
  local cfg = vim.lsp.config[server]
  if not cfg then return end
  vim.lsp.config[server] = vim.tbl_deep_extend('force', cfg, overrides or {}, {capabilities = capabilities})
  vim.lsp.enable(server)
end

enable('lua_ls')
enable('pyright')
enable('gopls')
enable('clangd')
enable('bashls')
enable('yamlls')
enable('marksman')
enable('tsserver')
enable('rust_analyzer')
