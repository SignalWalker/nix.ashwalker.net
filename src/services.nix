{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
in {
  options = with lib; {};
  disabledModules = [];
  imports = lib.signal.fs.path.listFilePaths ./services;
  config = {
    services."ashwalker-net" = {
      enable = true;
    };
  };
  meta = {};
}
