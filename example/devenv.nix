{ pkgs, lib, config, inputs, nixpkgs-unstable, ... }:
let
  unstable = import nixpkgs-unstable {
    system = pkgs.stdenv.system;
  };
  devenv-zsh = fetchTarball {
    url = "https://github.com/mcdonc/devenv-zsh/archive/master.tar.gz";
    sha256 = "sha256:0rkbhwbpirmm8g6qzcj7i8r3m5z1f8in5crmk3c7h896w3kw1g9x";
  };
    
in

{
  imports = [ (import "${devenv-zsh}") ];
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
