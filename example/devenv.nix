{ pkgs, lib, config, inputs, nixpkgs-unstable, ... }:
let
  unstable = import nixpkgs-unstable {
    system = pkgs.stdenv.system;
  };
in

{
  imports = [ ../zsh.nix ];
  processes.silly-example.exec = "while true; do echo hello && sleep 1; done";
  enterShell = ''
    echo "hello from bash at shell level $SHLVL!"
  '';
  zsh.enable = true;
  zsh.extraInit = ''
    echo "hello from zsh at shell level $SHLVL!"
  '';
  zsh.package = unstable.zsh;
}
