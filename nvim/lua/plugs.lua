local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
  execute 'packadd packer.nvim'
end

vim.cmd 'autocmd BufWritePost plugins.lua PackerCompile' -- Auto compile when there are changes in plugins.lua

-- require('packer').init({display = {non_interactive = true}})
require('packer').init({display = {auto_clean = false}})

return require('packer').startup(function(use)
  -- Packer can manage itself as an optional plugin
  use 'wbthomason/packer.nvim'

  -- Autocomplete
  use 'windwp/nvim-autopairs'
  use 'hrsh7th/vim-vsnip'
  use 'hrsh7th/vim-vsnip-integ'

  -- LSP
  use 'neovim/nvim-lspconfig'
  use 'folke/lsp-colors.nvim'
  use 'glepnir/lspsaga.nvim'
  use 'onsails/lspkind-nvim'
  use 'hrsh7th/nvim-compe'
  use {'tzachar/compe-tabnine', run='./install.sh', requires = 'hrsh7th/nvim-compe'}

  -- Treesitter
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'p00f/nvim-ts-rainbow'
  use 'romgrk/nvim-treesitter-context'
  use 'windwp/nvim-ts-autotag'

  -- Syntax
  use 'sheerun/vim-polyglot'
  use 'zinit-zsh/zplugin-vim-syntax'
  use 'editorconfig/editorconfig-vim'
  use 'elixir-editors/vim-elixir'

  -- Icons
  use {
      'yamatsum/nvim-web-nonicons',
      requires = {'kyazdani42/nvim-web-devicons'}
    }
  use 'ryanoasis/vim-devicons'

  -- Color
  use 'norcalli/nvim-colorizer.lua'

  -- Git
  use {
    'lewis6991/gitsigns.nvim',
    requires = {
      'nvim-lua/plenary.nvim'
    }
  }

  -- Telescope
  use {
  'nvim-telescope/telescope.nvim',
  requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
  }
  use 'nvim-telescope/telescope-media-files.nvim'

  -- Flutter
  -- use 'akinsho/flutter-tools.nvim'

  -- Tim Pope docet
  use 'tpope/vim-surround'
  use 'tpope/vim-endwise'
  use 'tpope/vim-fugitive'

  -- General Plugins
  use 'jeffkreeftmeijer/vim-numbertoggle'

  --UI
  use {'glepnir/galaxyline.nvim', branch = 'main'}
  -- use 'akinsho/nvim-bufferline.lua'
  -- use 'jose-elias-alvarez/buftabline.nvim'
  use {'seblj/nvim-tabline',
    requires = {'kyazdani42/nvim-web-devicons'}
  }
  use 'karb94/neoscroll.nvim'
  use {
  "folke/todo-comments.nvim",
  requires = "nvim-lua/plenary.nvim",
  }
  use {
  "folke/trouble.nvim",
  requires = "kyazdani42/nvim-web-devicons",
  }

  -- Text edition
  use {'mg979/vim-visual-multi', branch = 'master'}
  use 'b3nj5m1n/kommentary'
  use {'heavenshell/vim-pydocstring', run = 'make install' }
  use 'KabbAmine/vCoolor.vim'
  use 'AndrewRadev/splitjoin.vim'

  --Utils
  use 'numtostr/FTerm.nvim'
  use 'CRAG666/code_runner.nvim'

  -- Themes
  use 'franbach/miramare'
  use 'sainnhe/sonokai'
  use 'folke/tokyonight.nvim'
  use 'Matt-Gleich/blackbird.vim'
  use 'lmburns/kimbox'
  use 'eddyekofo94/gruvbox-flat.nvim'
end)
