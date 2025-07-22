
{
  description = "Dart Dev Shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
          "vscode-with-extensions"
          "vscode"
          "vscode-extension-mhutchie-git-graph"
        ];
      };
    };
    
  in 
  {
    # This just lets you execute "nix run" from within command line while in this folder to be instantly dropped into the vscode dev env
    packages.${system} = {
      default = pkgs.writeShellScriptBin "run" ''
        nix develop -c -- code .
      '';
    };

    devShells.${system}.default = pkgs.mkShell rec {
      name = "DartDevShell";
      buildInputs = with pkgs; [
        bashInteractive
        dart

        (vscode-with-extensions.override  {
          vscode = pkgs.vscode;
          vscodeExtensions = with pkgs.vscode-extensions; [
            jnoortheen.nix-ide
            mhutchie.git-graph
            
            dart-code.dart-code
          ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            # {
            #   name = "vscode-dotnet-pack";
            #   publisher = "ms-dotnettools";
            #   version = "1.0.13";
            #   sha256 = "sha256-z3xiXgWADSHdZM/+MSmqRXqDjiX4O6whevN1zSmByWQ=";
            # }
          ];
        })
      ];

      shellHook = ''
        export PS1+="${name}> "
        echo "Welcome to the Dart Dev Shell!"
      '';
    };
  };

}