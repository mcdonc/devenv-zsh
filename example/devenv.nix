{ pkgs, lib, config, inputs, nixpkgs, ... }:
let
  a-different-nixpkgs = import nixpkgs {
    system = pkgs.stdenv.system;
  };
in

{
  imports = [ ../zsh.nix ];
  enterShell = ''
   echo "hi from bash!"
  '';
  zsh.enable = true;
  zsh.extraInit = ''
    echo "hello from zsh!"
    function my_prompt_devenv() {
      # if [ -z "$DEVENV_ROOT" ]; then
      #   return
      # fi
      p10k segment -b 226 -f red -i $'\uF197' -t devenv
    }
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS+=my_prompt_devenv
    p10k reload
    echo $$
  '';
  zsh.package = a-different-nixpkgs.zsh;
}
