{
  programs.git = {
    enable = true;
    userEmail = "yuanjin233@gmail.com";
    userName = "Pixdane";
    extraConfig = {
      http.postbuffer = 524288000;
      core.autocrlf = false;
      core.eol = "lf";
    };
  };
}
