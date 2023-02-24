{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { self, nixpkgs }:
    let
      forEachSystem = nixpkgs.lib.genAttrs
        [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ];
    in
    {
      packages = forEachSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
          inherit (pkgs.poetry2nix)
            mkPoetryApplication overrides;
        in
        {
          default = mkPoetryApplication {
            projectDir = self;
            overrides = overrides.withDefaults (_: prev: {
              httpx-oauth = prev.httpx-oauth.overridePythonAttrs (old: {
                buildInputs = (old.buildInputs or [ ]) ++ [ prev.hatchling ];
              });
            });
          };
        });
    };
}
