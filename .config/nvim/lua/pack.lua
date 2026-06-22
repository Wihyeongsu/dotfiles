vim.pack.add({
    "https://github.com/bluz71/vim-moonfly-colors",
    "https://github.com/nvim-mini/mini.nvim",
    "https://github.com/rafamadriz/friendly-snippets",
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", branch = "main", build = ":TSUpdate"},
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/mason-org/mason.nvim",
})

for _, path in ipairs(vim.api.nvim_get_runtime_file('lua/plugins/mini/*.lua', true)) do
    local name = vim.fn.fnamemodify(path, ':t:r')
    require('plugins.mini.' .. name)
end

require("lsp")
require("plugins.treesitter")


