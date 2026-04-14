{ pkgs, ... }:
let
  vp = pkgs.vimPlugins;
  myPlugins = [
    vp.plenary-nvim
    vp.nvim-web-devicons
    vp.catppuccin-nvim
    (vp.nvim-treesitter.withAllGrammars)
    vp.nvim-lspconfig
    vp.cmp-nvim-lsp
    vp.cmp-buffer
    vp.cmp-path
    vp.cmp_luasnip
    vp.luasnip
    vp.nvim-cmp
    vp.telescope-fzf-native-nvim
    vp.telescope-nvim
    vp.oil-nvim
    vp.lualine-nvim
    vp.gitsigns-nvim
    vp.which-key-nvim
    vp.nvim-autopairs
    vp.comment-nvim
    vp.nui-nvim
    vp.neo-tree-nvim
  ];
  luaPath = builtins.concatStringsSep ";" (map (p: "${p}/lua/?.lua;${p}/lua/?/init.lua") myPlugins);
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    withRuby = false;
    withPython3 = false;

    extraPackages = with pkgs; [
      nil # Nix LSP
      lua-language-server # Lua LSP
      typescript-language-server # JS/TS LSP
      vscode-langservers-extracted # JSON, HTML, CSS LSP
      ripgrep # telescope live grep
      fd # telescope file finding
    ];

    plugins = myPlugins;

    initLua = ''
      -- Add plugin lua dirs to package.path so require() finds them
      package.path = "${luaPath};" .. package.path

      -- ============================================================
      -- Options
      -- ============================================================
      vim.g.mapleader      = " "
      vim.g.maplocalleader = " "

      vim.opt.number         = true
      vim.opt.relativenumber = true
      vim.opt.tabstop        = 2
      vim.opt.shiftwidth     = 2
      vim.opt.expandtab      = true
      vim.opt.smartindent    = true
      vim.opt.wrap           = false
      vim.opt.ignorecase     = true
      vim.opt.smartcase      = true
      vim.opt.hlsearch       = false
      vim.opt.incsearch      = true
      vim.opt.termguicolors  = true
      vim.opt.scrolloff      = 8
      vim.opt.signcolumn     = "yes"
      vim.opt.updatetime     = 50
      vim.opt.splitright     = true
      vim.opt.splitbelow     = true
      vim.opt.undofile       = true
      vim.opt.clipboard      = "unnamedplus"

      -- ============================================================
      -- Keymaps
      -- ============================================================
      vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })
      vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

      -- Window navigation
      vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
      vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom split" })
      vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top split" })
      vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

      -- Move selected lines
      vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
      vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

      -- Clipboard
      vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
      vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })

      -- ============================================================
      -- Colorscheme
      -- ============================================================
      require("catppuccin").setup({ flavour = "mocha" })
      vim.cmd.colorscheme("catppuccin")

      -- ============================================================
      -- Treesitter
      -- ============================================================
      require("nvim-treesitter.config").setup({
        highlight = { enable = true },
        indent   = { enable = true },
      })

      -- ============================================================
      -- LSP
      -- ============================================================
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
          end
          local tb = require("telescope.builtin")
          map("gd",         vim.lsp.buf.definition,   "Go to definition")
          map("gD",         vim.lsp.buf.declaration,  "Go to declaration")
          map("gr",         tb.lsp_references,         "References")
          map("gi",         tb.lsp_implementations,   "Implementations")
          map("K",          vim.lsp.buf.hover,         "Hover docs")
          map("<leader>ca", vim.lsp.buf.code_action,   "Code action")
          map("<leader>rn", vim.lsp.buf.rename,        "Rename symbol")
          map("<leader>d",  vim.diagnostic.open_float, "Open diagnostic")
          map("[d",         vim.diagnostic.goto_prev,  "Previous diagnostic")
          map("]d",         vim.diagnostic.goto_next,  "Next diagnostic")
        end,
      })

      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace   = { checkThirdParty = false },
            telemetry   = { enable = false },
          },
        },
      })

      vim.lsp.enable({ "nil_ls", "lua_ls", "ts_ls", "jsonls", "html", "cssls" })

      -- ============================================================
      -- Completion
      -- ============================================================
      local cmp     = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      -- ============================================================
      -- Telescope
      -- ============================================================
      require("telescope").setup({
        extensions = { fzf = {} },
      })
      require("telescope").load_extension("fzf")

      local tb = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", tb.find_files,  { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", tb.live_grep,   { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", tb.buffers,     { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>fh", tb.help_tags,   { desc = "Help tags" })
      vim.keymap.set("n", "<leader>fd", tb.diagnostics, { desc = "Diagnostics" })

      -- ============================================================
      -- File explorer
      -- ============================================================
      require("oil").setup({ default_file_explorer = true })
      vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "File explorer" })

      -- ============================================================
      -- File tree (sidebar)
      -- ============================================================
      require("neo-tree").setup({
        close_if_last_window = true,
        window = { width = 30 },
        filesystem = {
          follow_current_file = { enabled = true },
          hijack_netrw_behavior = "disabled",
        },
      })
      vim.keymap.set("n", "<leader>E", "<cmd>Neotree toggle<cr>", { desc = "Toggle file tree" })

      -- ============================================================
      -- Statusline
      -- ============================================================
      require("lualine").setup({})

      -- ============================================================
      -- Git decorations
      -- ============================================================
      require("gitsigns").setup({
        signs = {
          add          = { text = "│" },
          change       = { text = "│" },
          delete       = { text = "󰍵" },
          topdelete    = { text = "‾" },
          changedelete = { text = "~" },
        },
      })

      -- ============================================================
      -- Keybinding hints
      -- ============================================================
      require("which-key").setup()

      -- ============================================================
      -- Auto pairs
      -- ============================================================
      require("nvim-autopairs").setup()

      -- ============================================================
      -- Commenting
      -- ============================================================
      require("Comment").setup()
    '';
  };
}
