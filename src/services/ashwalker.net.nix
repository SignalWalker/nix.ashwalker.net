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
  imports = [];
  config = {
    services."ashwalker-net" = {
      enable = true;
      ssl = {
        enable = true;
        autoRenewEmail = "ash@ashwalker.net";
      };
    };
  };
  meta = {};
}