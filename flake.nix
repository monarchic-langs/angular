{
  description = "Nix package for Angular language server";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    angular-language-server = pkgs.angular-language-server;
  in {
    formatter.${system} = pkgs.alejandra;

    packages = {
      ${system}.default = angular-language-server;
    };

    checks = {
      ${system} = {
        package = angular-language-server;

        format = pkgs.runCommand "angular-flake-format" {nativeBuildInputs = [pkgs.alejandra];} ''
          alejandra --check ${./flake.nix}
          touch $out
        '';

        smoke = pkgs.runCommand "angular-language-server-smoke" {nativeBuildInputs = [angular-language-server];} ''
          command -v ngserver
          ngserver --help
          touch $out
        '';
      };
    };

    devShells.${system}.default = pkgs.mkShell {
      packages = [angular-language-server pkgs.pnpm];
    };
  };
}
