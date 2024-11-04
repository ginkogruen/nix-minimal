{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.custom.ssh;
in {
  options.custom = {
    ssh.enable = mkEnableOption "Enable SSH hm-module";
  };
  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      addKeysToAgent = "yes";
    };

    services.ssh-agent.enable = true;
  };
}
