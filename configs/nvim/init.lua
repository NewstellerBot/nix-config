-- Load packer_compiled from data dir (nix store makes config dir read-only)
local compiled_path = vim.fn.stdpath("data") .. "/packer_compiled.lua"
if vim.fn.filereadable(compiled_path) == 1 then
  vim.cmd("source " .. compiled_path)
end

require("krystian")
