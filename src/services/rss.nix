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
    services.tt-rss = {
      enable = true;
      pubSubHubbub.enable = true;
      selfUrlPath = "https://${config.services.tt-rss.virtualHost}";
      registration = {
        enable = false;
        notifyAddress = "ash@ashwalker.net";
        maxUsers = 1;
      };
      virtualHost = "rss.${config.networking.fqdn}";
    };
    services.nginx.virtualHosts.${config.services.tt-rss.virtualHost} = {
      enableACME = true;
      addSSL = true;
    };
  };
  meta = {};
}
