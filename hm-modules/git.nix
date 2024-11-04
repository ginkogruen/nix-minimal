{config, lib, ...}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.custom.git;
in
{
  options.custom = {
    git.enable = mkEnableOption "Enable git hm-module";
  };
  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      extraConfig = {
        init = {
	  defaultBranch = "main";
	};
      };
    };
  };
}
