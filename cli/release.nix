{ pkgs ? null } @ args:

let
  pkgs = (import (../.nix/release.nix) {}).ensurePkgs args;
in

with pkgs;

let
  pythonPackages = python3Packages;

  default = pythonPackages.callPackage ./. {};

  dev = default.overridePythonAttrs (old: {
    dependencies = (old.dependencies or [])
      ++ (with pythonPackages; [
        pytest
        mypy
        flake8
        ipython
        autopep8
        isort
      ]);

  /*
  TODO: Review the need for those things.
  ${nsfPy.shell.runSetuptoolsShellHook "${builtins.toString ./.}" default pythonPackages}
  ${nsfShC.shell.loadClickExesBashCompletion [ "nsf-ssh-auth-dir" ]}
  source ${nsfPy.shell.shellHookLib}
  nsf_py_set_interpreter_env_from_path
  */

    # shellHook = with nsf-py-nix-lib; with nsf-shc-nix-lib; ''
    # '';
  });

in

rec {
  inherit default;

  shell = {
    installed = mkShell {
      name = "${default.pname}-installed-shell";

      buildInputs = [ default ];

      shellHook = with nsf-shc-nix-lib; ''
        ${nsfShC.env.exportXdgDataDirsOf ([ default ] ++ default.buildInputs)}
        ${nsfShC.env.ensureDynamicBashCompletionLoaderInstalled}
      '';
    };

    inherit dev;
  };
}
