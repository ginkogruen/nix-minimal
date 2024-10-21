{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.ssh;
in {
  options = {
    custom.ssh.enable = mkEnableOption "Enable ssh hm-module";
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      addKeysToAgent = "yes";
      extraConfig = ''
        VisualHostKey yes
      '';
      matchBlocks = {
        "github.com" = {
          hostname = "github.com";
          identityFile = "~/.ssh/id_ed25519";
        };
      };
    };
  };
}
