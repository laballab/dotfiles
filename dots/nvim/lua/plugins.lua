-- plugin configs

local function has(mod)
  local ok, m = pcall(require, mod)
  if ok then return m end
end

local function setup_cmp()
  local cmp = has('cmp')
  if not cmp then return end

  local luasnip = has('luasnip')
  if luasnip then
    local loader = has('luasnip.loaders.from_vscode')
    if loader then loader.lazy_load() end
  end

  local function tab(dir)
    return cmp.mapping(function(fallback)
      if cmp.visible() then
        if dir == 1 then cmp.select_next_item() else cmp.select_prev_item() end
        return
      end
      if luasnip then
        if dir == 1 and luasnip.expand_or_jumpable() then luasnip.expand_or_jump(); return end
        if dir == -1 and luasnip.jumpable(-1) then luasnip.jump(-1); return end
      end
      fallback()
    end, { 'i', 's' })
  end

  cmp.setup({
    completion = { autocomplete = false }, -- only show completion when manually triggered
    snippet = {
      expand = function(args)
        if luasnip then luasnip.lsp_expand(args.body) end
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
      ['<Tab>'] = tab(1),
      ['<S-Tab>'] = tab(-1),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'path' },
      { name = 'buffer' },
    }),
  })

  local autopairs = has('nvim-autopairs')
  if autopairs then
    autopairs.setup({})
    local cmp_ap = has('nvim-autopairs.completion.cmp')
    if cmp_ap and cmp.event then
      cmp.event:on('confirm_done', cmp_ap.on_confirm_done())
    end
  end

  pcall(function()
    local types = require('cmp.types')
    local autocomplete = { types.cmp.TriggerEvent.TextChanged }
    local cmdline_map = vim.tbl_extend('force', cmp.mapping.preset.cmdline(), {
      ['<C-Space>'] = cmp.mapping.complete(),
    })
    cmp.setup.cmdline(':', {
      mapping = cmdline_map,
      sources = cmp.config.sources({ { name = 'path' } }, { { name = 'cmdline' } }),
      completion = { autocomplete = autocomplete },
    })
    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmdline_map,
      sources = { { name = 'buffer' } },
      completion = { autocomplete = autocomplete },
    })
  end)
end

local function setup_tsttr()
  local ts = has('nvim-treesitter.configs')
  if not ts then return end
  local cfg = {
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = 'gnn',
      },
    },
  }
  ts.setup(cfg)
end

local function setup_tsttr_ctx()
  local ctx = has('treesitter-context')
  if not ctx then return end
  ctx.setup({max_lines = 3})
end

local function setup_trouble()
  local trouble = has('trouble')
  if not trouble then return end

  trouble.setup({
    auto_preview = true,
    follow = true,
    indent_lines = true,
    warn_no_results = false,
  })

  local function toggle(mode, opts)
    return function() trouble.toggle(mode, opts) end
  end

  local map = vim.keymap.set
  map('n', '<leader>cl', toggle('lsp', {focus=false, win={position='right'}}), {desc='lsp'})
  map('n', '<leader>xx', toggle('diagnostics'), {desc='diag'})
  map('n', '<leader>xs', toggle('symbols'), {desc='symbols'})
  map('n', 'gR', toggle('lsp_references'), {desc='refs'})
end

setup_cmp()
setup_tsttr()
setup_tsttr_ctx()
setup_trouble()
