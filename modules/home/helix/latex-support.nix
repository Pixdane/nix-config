{pkgs, ...}: {
  programs.helix.languages = {
    language = [
      {
        name = "latex";
        indent = {
          tab-width = 4;
          unit = "    ";
        };
        formatter.command = "tex-fmt";
        auto-format = true;
      }

      {
        name = "bibtex";
        indent = {
          tab-width = 4;
          unit = "    ";
        };
      }
    ];

    language-server.texlab.config.texlab = {
      chktex = {
        onOpenAndSave = true;
        onEdit = true;
      };
      build = {
        forwardSearchAfter = true;
        onSave = true;
        auxDirectory = "build";
        logDirectory = "build";
        pdfDirectory = "build";

        executable = "latexmk";
        args = [
          "-cd"
          "-xelatex"
          "-interaction=nonstopmode"
          "-synctex=1"
          "-shell-escape"
          "-output-directory=build"
          "%f"
        ];
      };
      forwardSearch = {
        executable = "/Applications/Skim.app/Contents/SharedSupport/displayline";
        args = [
          "-r"
          "%l"
          "%p"
          "%f"
        ];
      };
    };
  };
}
