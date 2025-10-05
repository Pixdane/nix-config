{pkgs, ...}: {
  programs.helix.settings = {
    theme = "catppuccin_mocha_modified";

    editor = {
      line-number = "relative";
      mouse = true;
      shell = ["fish" "-c"];
      soft-wrap.enable = true;

      cursor-shape = {
        insert = "bar";
        normal = "block";
        select = "underline";
      };

      file-picker.hidden = false;

      statusline = {
        right = [
          "diagnostics"
          "selections"
          "register"
          "position"
          "position-percentage"
          "file-encoding"
          "file-type"
        ];
      };
    };

    # commands.latex = {
    #   "p" = ":sh open ";
    # };
  };
}
