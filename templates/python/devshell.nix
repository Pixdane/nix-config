{
  pkgs,
  inputs,
}: let
  python = pkgs.python313;
in
  pkgs.mkShell {
    packages = [
      python
      pkgs.uv
    ];

    # Add environment variables
    env = {
      UV_PYTHON = python.interpreter;
      UV_PYTHON_DOWNLOADS = "never";
    };

    # Load custom bash code
    shellHook = ''
      unset PYTHONPATH
      uv sync
      . .venv/bin/activate
    '';
  }
