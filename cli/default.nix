{ lib
, buildPythonPackage
, mypy
, pytest
, flake8
, ipython
, click
, pyyaml
, setuptools
, nix-gitignore
, nsf-shc-nix-lib
}:

let
  attrs = builtins.fromTOML (builtins.readFile ./pyproject.toml);
  pname = attrs.project.name;
  inherit (attrs.project) version;
in

buildPythonPackage rec  {
  inherit pname version;
  pyproject = true;

  src = nix-gitignore.gitignoreSourcePure ../.gitignore ./.;

  build-system = [
    setuptools
  ];

  dependencies = [
    click
    pyyaml
  ];

  doCheck = false;

  nativeCheckInputs = [
    mypy
    pytest
    flake8
  ];

  checkPhase = ''
    mypy .
    pytest .
    flake8
  '';

  postInstall =  with nsf-shc-nix-lib; ''
    ${nsfShC.pkg.installClickExesBashCompletion [
      "nsf-ssh-auth-dir"
    ]}
  '';

  pythonImportsCheck = [
    "nsf_ssh_auth_dir"
    "nsf_ssh_auth_dir.cli"
  ];

  # TODO: Review our approach here. The goal was to replicate the
  # previous behavior of exposing the python package's scripts from
  # the pyproject file.
  shellHook = let
    attrs = builtins.fromTOML (builtins.readFile ./pyproject.toml);
    scripts = attrs.project.scripts;
    renderFn = scriptName: scriptEntry: let
      parts = (lib.strings.splitString ":" scriptEntry);
      module = builtins.elemAt parts 0;
      main = builtins.elemAt parts 1;
    in ''
      alias ${scriptName}="python -c 'import sys; from ${module} import ${main} as main; sys.exit(main())'"
    '';

  in ''
    export "PYTHONPATH=${toString ./.}/src"
    ${builtins.concatStringsSep "\n" (lib.mapAttrsToList renderFn scripts)}
  '';

  # PYTHONPATH="$PWD/src:$PYTHONPATH" python -c 'import sys; from nsf_ssh_auth_dir.cli import run_cli_nsf_ssh_auth_dir as main; sys.exit(main())'
}
