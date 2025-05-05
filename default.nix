{ pkgs, lib, config, inputs, ... }:
let
  strToBool = str: str != "";
  cfg = config.zsh;
  # use zshi instead of recreating it, although it is a bit slow
  zshi = pkgs.stdenv.mkDerivation {
    name="devenv-zsh-zshi";
    src = pkgs.fetchFromGitHub {
      owner = "romkatv";
      repo = "zshi";
      rev = "c9c90687448a1f0aae30d9474026de608dc90734";
      sha256 = "sha256-OB96i93ZxKDgOqIFq1jM9l+wxAisRXtSCBcHbYDvxsI=";
    };
    installPhase = ''
      mkdir -p $out/bin
      cp zshi $out/bin/zshi
      substituteInPlace $out/bin/zshi \
        --replace '/usr/bin/env zsh' ${cfg.package}/bin/zsh
    '';
    meta = with lib; {
      description = "ZSH -i except initial command exec'd after std zsh files";
      homepage = "https://github.com/romkatv/zshi";
      license = licenses.mit;
      platforms = platforms.all;
    };
  };
  extra-init = pkgs.writeText "devenv-zsh-extra-init" "${cfg.extraInit}";
in
{
  options.zsh = {
    enable = lib.mkOption {
      type = lib.types.bool;
      description = "Use zsh in interactive devenv shell";
      default = true;
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.zsh;
      defaultText = lib.literalExpression "pkgs.zsh";
      description = "The ZSH pacakge to use";
    };
    extraInit = lib.mkOption {
      type = lib.types.str;
      description = ''
        ZSH-specific commands run after global ZSH initialilzation.
     '';
      default = "";
    };
  };
  config =
    let
      normal-zsh = ''${cfg.package}/bin/zsh -i'';
      shimmed-zsh = ''${zshi}/bin/zshi ". ${extra-init}"'';
      zsh-command = if strToBool(cfg.extraInit) then shimmed-zsh else normal-zsh;
    in
    lib.mkIf cfg.enable {
      enterShell = lib.mkAfter ''
        # not disabled
        if [ "$DEVENV_ZSH_DISABLE" == "0" ] || [ -z "$DEVENV_ZSH_DISABLE" ];then
          # XXX hack: don't break "devenv up"
          if [ -z "$_DEVENV_ZSH_EXECED" ]; then
            export _DEVENV_ZSH_EXECED="$SHLVL"
            exec ${zsh-command}
          fi
        fi
      '';
    };
}
