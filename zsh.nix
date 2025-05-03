{ pkgs, lib, config, inputs, ... }:
let
  stringToBool = str: str != "";
  cfg = config.zsh;
  zsh-shimdir = pkgs.runCommand "devenv-zsh-shimdir" {} ''
    mkdir -p $out

    cat > $out/.zshenv <<EOF
# zsh interactive shell startup file read order:
# /etc/zshenv
# $ZDOTDIR/.zshenv
# /etc/zshrc
# $ZDOTDIR/.zshrc

SHIM_ZDOTDIR="$out"

if [ -e "\$GLOBAL_ZDOTDIR/.zshenv" ]; then
  . "\$GLOBAL_ZDOTDIR/.zshenv"
fi

# if the global zshenv resets the zdotdir, reset it to the shim directory so
# we evaluate the shim directory's .zshrc
if [[ "\$ZDOTDIR" != "\$SHIM_ZDOTDIR" ]]; then
  export GLOBAL_ZDOTDIR="\$ZDOTDIR"
  export ZDOTDIR="\$SHIM_ZDOTDIR"
fi
EOF

    cat > $out/.zshrc <<'EOF'
export ZDOTDIR="$GLOBAL_ZDOTDIR"

if [ -e "$GLOBAL_ZDOTDIR/.zshrc" ]; then
  . "$GLOBAL_ZDOTDIR/.zshrc"
fi
${cfg.extraInit}
unset GLOBAL_ZDOTDIR
EOF
'';
  zsh-shim = pkgs.runCommand "devenv-zsh-shim" {} ''
    mkdir -p $out

    cat > $out/zsh <<'EOF'
# allow local configuration of zsh, because non-inherited resources like
# aliases may need to be redefined
GZ="$ZDOTDIR"
if [ -z "$GZ" ]; then
  GZ="$HOME"
fi
LZ="${zsh-shimdir}"
GLOBAL_ZDOTDIR="$GZ" ZDOTDIR="$LZ" "${cfg.package}/bin/zsh" $@
EOF
chmod 755 $out/zsh
'';
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
      normal-zsh = ''exec ${cfg.package}/bin/zsh -i'';
      shimmed-zsh = ''exec ${zsh-shim}/zsh -i'';
      zsh-command = if stringToBool(cfg.extraInit) then shimmed-zsh else
        normal-zsh;
    in
    lib.mkIf cfg.enable {
      enterShell = lib.mkAfter zsh-command;
    };

}
