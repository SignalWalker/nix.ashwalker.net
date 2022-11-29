{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  vhost = "wiki.${config.networking.fqdn}";
  wiki = config.services.mediawiki;
  phpfpm = config.services.phpfpm.pools.mediawiki;
in {
  options = with lib; {
    signal.services.wiki = {
      enable = (mkEnableOption "wiki") // {default = false;};
    };
  };
  disabledModules = [];
  imports = [
    ./wiki/mediawiki.nix
  ];
  config = lib.mkIf config.signal.services.wiki.enable {
    age.secrets.wikiAdminPassword = {
      file = ./wiki/wikiAdminPassword.age;
      owner = wiki.user;
      group = wiki.group;
    };
    age.secrets.wikiSecrets = {
      file = ./wiki/wikiSecrets.age;
      owner = wiki.user;
      group = wiki.group;
    };
    services.mediawiki = {
      enableSignal = true;
      name = "SignalWiki";
      passwordFile = config.age.secrets.wikiAdminPassword.path;
      secretsFile = config.age.secrets.wikiSecrets.path;
      database = {
        type = "mysql";
      };
      reverseProxy = {
        type = "nginx";
        hostName = vhost;
      };
      settings = {
        wgArticlePath = "/wiki/$1";
        wgServer = "//${wiki.reverseProxy.hostName}";
        wgCanonicalServer = "https:${wiki.settings.wgServer}";
        wgCapitalLinks = false;
      };
    };
    services.nginx.virtualHosts.${wiki.reverseProxy.hostName} = {
      enableACME = true;
      forceSSL = true;
      locations."= /favicon.ico" = lib.mkForce {
        proxyPass = "https://ashwalker.net/favicon.ico";
        extraConfig = ''
          add_header Cache-Control "public";
          expires 7d;
        '';
      };
    };
  };
  meta = {};
}
