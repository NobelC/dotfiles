-- Carga el colorscheme generado dinamicamente por Aether.
-- Si Aether aun no genero el tema (maquina nueva, primer arranque),
-- cae de vuelta a un colorscheme de LazyVim por defecto.

local theme_path = vim.fn.expand("~/.config/aether/theme/neovim.lua")

if vim.fn.filereadable(theme_path) == 1 then
  return dofile(theme_path)
end

-- Fallback: tokyonight, coherente con el resto de tu setup
return {
  { "folke/tokyonight.nvim" },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
