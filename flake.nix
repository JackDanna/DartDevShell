{
  description = "Dart Dev Shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:

  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
            "vscode-with-extensions"
            "vscode"
            "vscode-extension-mhutchie-git-graph"
          ];
          android_sdk.accept_license = true;
          allowUnfree = true;
        };
      };
      androidComposition = pkgs.androidenv.composeAndroidPackages {
        cmdLineToolsVersion = "8.0";
        toolsVersion = "26.1.1";
        platformToolsVersion = "34.0.5";
        buildToolsVersions = [ "30.0.3" "34.0.0" ];
        includeEmulator = false;
        emulatorVersion = "34.1.9";
        platformVersions = [ "28" "29" "30" "31" "32" "33" "34" ];
        includeSources = false;
        includeSystemImages = false;
        systemImageTypes = [ "google_apis_playstore" ];
        abiVersions = [ "armeabi-v7a" "arm64-v8a" ];
        cmakeVersions = [ "3.10.2" ];
        includeNDK = false;
        ndkVersions = ["21.4.7075529"];
        useGoogleAPIs = false;
        useGoogleTVAddOns = false;
        includeExtras = [
          "extras;google;gcm"
        ];
      };
      androidSdk = androidComposition.androidsdk;
    in
    {
      # This just lets you execute "nix run" from within command line while in this folder to be instantly dropped into the vscode dev env
      packages.default = pkgs.writeShellScriptBin "run" ''
        nix develop -c -- code .
      '';

      devShells.default = pkgs.mkShell rec {
        name = "DartDevShell";
        ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
        buildInputs = with pkgs; [
          
          flutter
          androidSdk
          jdk17

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
    });
}