{
  description = "devenv-zsh";

  inputs = {};

  outputs = { self }:
    {
      plugin = (import ./default.nix);
    };
}
