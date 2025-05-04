{
  description = "devenv-zsh";

  inputs = {};

  outputs = { self }:
    let
      plugin = (import ./default.nix);
    in
    {
      plugin = plugin;
      default = plugin;
    };
}
