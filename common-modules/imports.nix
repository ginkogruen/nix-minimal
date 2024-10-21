{
  config,
  lib,
  ...
}: {
  imports = [
    /*
    Don't import modules through here.
    Modules in common-modules are meant to be
    imported through hm, nixos or darwin -modules.
    This is just a placeholder to avoid confusion.
    */
  ];

  options = {
    custom.common-modules.imports.enable = lib.mkEnableOption "Enable common-modules/imports.nix modules";
  };

  config = {
    custom.common-modules.imports.enable = true;

    warnings =
      if config.custom.common-modules.imports.enable
      then [
        ''          The module '/common-modules/import.nix' seems to be imported directly.
                 It is not meant to be used due to how 'common-modules' are envisioned. ''
      ]
      else [];
  };
}
