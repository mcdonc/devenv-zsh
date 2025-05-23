{ pkgs, lib, config, inputs, ... }:
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
      description = "ZSH-specific commands run after global ZSH init.";
      default = "";
    };
  };
  config =
    let
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
            --replace '/usr/bin/env zsh' ${cfg.package}/bin/zsh \
            --replace 'ZDOTDIR=$tmp zsh' 'ZDOTDIR=$tmp ${cfg.package}/bin/zsh'
        '';
        meta = with lib; {
          description = "ZSH -i but initial command exec'd after std zsh files";
          homepage = "https://github.com/romkatv/zshi";
          license = licenses.mit;
          platforms = platforms.all;
        };
      };
      strToBool = str: str != "";
      extra-init = pkgs.writeText "devenv-zsh-extra-init" "${cfg.extraInit}";
      normal-zsh = ''${cfg.package}/bin/zsh -i'';
      shim-zsh = ''${zshi}/bin/zshi ". ${extra-init}"'';
      zsh-command = if strToBool(cfg.extraInit) then shim-zsh else normal-zsh;
    in
      lib.mkIf cfg.enable {
        enterShell = lib.mkAfter ''
        if [ "$DEVENV_ZSH_DISABLE " == "0" ] || \
                [ -z "$DEVENV_ZSH_DISABLE" ]; then
          # not disabled
          if [ -z "''${DEVENV_CMDLINE+x}" ]; then
            # DEVENV_CMDLINE is unset; devenv before 1.7
            if [ -z "$_DEVENV_ZSH_EXECED" ]; then
              # XXX hack: don't break "devenv up"
              export _DEVENV_ZSH_EXECED="$SHLVL"
              exec ${zsh-command}
            fi
          elif [[ "$DEVENV_CMDLINE" == "shell" ]]; then
            # DEVENV_CMDLINE is set (devenv 1.7+), and == "shell"
            exec ${zsh-command}
          fi
        fi
      '';
      };
}
